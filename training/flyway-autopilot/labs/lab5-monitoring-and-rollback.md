---
layout: single
title: "Lab 5: Monitoring and Rollback"
description: "Implement comprehensive monitoring and establish robust rollback procedures"
toc: true
toc_label: "Lab Steps"
toc_icon: "tasks"
prev_lab:
  title: "Lab 4: Version Control"
  url: "/database-devops-autopilot/training/flyway-autopilot/labs/lab4-version-control"
next_lab:
  title: "Lab 6: Best Practices"
  url: "/database-devops-autopilot/training/flyway-autopilot/labs/lab6-best-practices"
---

# Lab 5: Monitoring and Rollback

Implement comprehensive monitoring systems and establish robust rollback procedures to ensure database deployment reliability and quick recovery from issues.

## Learning Objectives

- Set up database deployment monitoring
- Implement automated alerting systems
- Create comprehensive rollback procedures
- Establish incident response workflows

## Prerequisites

- Completed Labs 1-4
- Access to monitoring tools (Prometheus, Grafana, etc.)
- Understanding of alerting systems
- Database administration privileges

## Step 1: Monitoring Setup

### Flyway Autopilot Monitoring Configuration

```yaml
# monitoring/flyway-monitoring.yml
version: "3.8"
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - ./grafana/dashboards:/var/lib/grafana/dashboards

  flyway-exporter:
    image: flyway/prometheus-exporter:latest
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=jdbc:postgresql://db:5432/myapp
      - DATABASE_USER=monitor_user
      - DATABASE_PASSWORD=monitor_password
```

### Prometheus Configuration

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "flyway-autopilot"
    static_configs:
      - targets: ["flyway-exporter:8080"]
    scrape_interval: 30s

  - job_name: "database"
    static_configs:
      - targets: ["postgres-exporter:9187"]
    scrape_interval: 30s
```

### Database Metrics Collection

```sql
-- monitoring/create_monitoring_views.sql
-- Create view for migration status monitoring
CREATE OR REPLACE VIEW migration_status AS
SELECT
    installed_rank,
    version,
    description,
    type,
    script,
    checksum,
    installed_by,
    installed_on,
    execution_time,
    success
FROM flyway_schema_history
ORDER BY installed_rank DESC;

-- Create view for database performance metrics
CREATE OR REPLACE VIEW db_performance_metrics AS
SELECT
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    n_tup_ins,
    n_tup_upd,
    n_tup_del
FROM pg_stat_user_tables;

-- Grant access to monitoring user
GRANT SELECT ON migration_status TO monitor_user;
GRANT SELECT ON db_performance_metrics TO monitor_user;
```

## Step 2: Alerting Configuration

### Alert Rules for Migration Failures

```yaml
# monitoring/alerts.yml
groups:
  - name: flyway-autopilot-alerts
    rules:
      - alert: MigrationFailed
        expr: flyway_migration_failed_total > 0
        for: 0m
        labels:
          severity: critical
        annotations:
          summary: "Database migration has failed"
          description: "Migration {{ $labels.version }} failed with error: {{ $labels.error }}"

      - alert: MigrationDurationHigh
        expr: flyway_migration_duration_seconds > 300
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Migration taking longer than expected"
          description: "Migration {{ $labels.version }} has been running for {{ $value }} seconds"

      - alert: SchemaValidationError
        expr: flyway_validation_errors_total > 0
        for: 0m
        labels:
          severity: critical
        annotations:
          summary: "Schema validation errors detected"
          description: "{{ $value }} validation errors found in schema"
```

### Notification Channels

```yaml
# monitoring/alertmanager.yml
global:
  smtp_smarthost: "localhost:587"
  smtp_from: "alerts@company.com"

route:
  group_by: ["alertname"]
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: "web.hook"
  routes:
    - match:
        severity: critical
      receiver: "database-team"

receivers:
  - name: "web.hook"
    webhook_configs:
      - url: "http://127.0.0.1:5001/"

  - name: "database-team"
    email_configs:
      - to: "database-team@company.com"
        subject: "CRITICAL: Database Migration Alert"
        body: |
          Alert: {{ range .Alerts }}{{ .Annotations.summary }}
          Description: {{ .Annotations.description }}{{ end }}
    slack_configs:
      - api_url: "YOUR_SLACK_WEBHOOK_URL"
        channel: "#database-alerts"
        title: "Database Migration Alert"
        text: "{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}"
```

## Step 3: Comprehensive Rollback Procedures

### Automatic Rollback Triggers

```bash
#!/bin/bash
# scripts/auto-rollback.sh
# Automatic rollback based on health checks

DEPLOYMENT_ID=$1
HEALTH_CHECK_URL=$2
MAX_FAILURES=3
CHECK_INTERVAL=30

echo "Starting health check monitoring for deployment $DEPLOYMENT_ID"

failure_count=0

while [ $failure_count -lt $MAX_FAILURES ]; do
    if curl -f -s "$HEALTH_CHECK_URL" > /dev/null; then
        echo "Health check passed"
        failure_count=0
    else
        echo "Health check failed (attempt $((failure_count + 1))/$MAX_FAILURES)"
        failure_count=$((failure_count + 1))
    fi

    if [ $failure_count -eq $MAX_FAILURES ]; then
        echo "Maximum failures reached. Initiating automatic rollback..."
        ./rollback-migration.sh $DEPLOYMENT_ID
        exit 1
    fi

    sleep $CHECK_INTERVAL
done
```

### Rollback Procedure with Data Preservation

```bash
#!/bin/bash
# scripts/rollback-migration.sh
# Comprehensive rollback with data backup

DEPLOYMENT_ID=$1
ROLLBACK_VERSION=$2

if [ -z "$DEPLOYMENT_ID" ] || [ -z "$ROLLBACK_VERSION" ]; then
    echo "Usage: $0 <deployment_id> <rollback_version>"
    exit 1
fi

echo "Starting rollback procedure for deployment $DEPLOYMENT_ID"

# Step 1: Create emergency backup
BACKUP_NAME="emergency_backup_${DEPLOYMENT_ID}_$(date +%Y%m%d_%H%M%S)"
echo "Creating emergency backup: $BACKUP_NAME"

if ! pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME -f "backups/$BACKUP_NAME.sql"; then
    echo "Backup failed! Aborting rollback."
    exit 1
fi

# Step 2: Stop application traffic
echo "Stopping application traffic..."
./scripts/maintenance-mode.sh enable

# Step 3: Execute rollback
echo "Executing rollback to version $ROLLBACK_VERSION"

if flyway undo -target=$ROLLBACK_VERSION; then
    echo "Rollback completed successfully"

    # Step 4: Verify rollback
    if ./scripts/verify-rollback.sh $ROLLBACK_VERSION; then
        echo "Rollback verification passed"

        # Step 5: Resume application traffic
        ./scripts/maintenance-mode.sh disable

        echo "Rollback procedure completed successfully"
    else
        echo "Rollback verification failed!"
        exit 1
    fi
else
    echo "Rollback failed! Database may be in inconsistent state."
    echo "Emergency backup available at: backups/$BACKUP_NAME.sql"
    exit 1
fi
```

### Data-Safe Rollback Strategy

```sql
-- migrations/U004__Undo_authentication_safe.sql
-- Safe rollback that preserves critical data

-- Step 1: Back up data from columns to be dropped
CREATE TABLE temp_user_auth_backup AS
SELECT
    id,
    password_hash,
    last_login,
    failed_login_attempts,
    account_locked_until
FROM users
WHERE password_hash IS NOT NULL;

-- Step 2: Back up sessions data
CREATE TABLE temp_sessions_backup AS
SELECT * FROM user_sessions;

-- Step 3: Drop foreign key constraints first
ALTER TABLE user_sessions DROP CONSTRAINT user_sessions_user_id_fkey;

-- Step 4: Drop new tables
DROP TABLE user_sessions;

-- Step 5: Remove columns from users table
ALTER TABLE users DROP COLUMN password_hash;
ALTER TABLE users DROP COLUMN last_login;
ALTER TABLE users DROP COLUMN failed_login_attempts;
ALTER TABLE users DROP COLUMN account_locked_until;

-- Step 6: Create restore script for future reference
DO $$
BEGIN
    RAISE NOTICE 'Rollback completed. Backup data preserved in:';
    RAISE NOTICE '- temp_user_auth_backup';
    RAISE NOTICE '- temp_sessions_backup';
    RAISE NOTICE 'To restore data, run restore-auth-data.sql';
END $$;
```

## Step 4: Incident Response Procedures

### Incident Response Playbook

```markdown
# Database Incident Response Playbook

## Severity Levels

### P0 - Critical (Database Down)

- **Response Time**: Immediate (< 5 minutes)
- **Actions**:
  1. Engage on-call DBA immediately
  2. Assess scope of impact
  3. Initiate emergency rollback if migration-related
  4. Communicate to stakeholders

### P1 - High (Performance Degradation)

- **Response Time**: < 15 minutes
- **Actions**:
  1. Identify root cause
  2. Implement quick fixes if available
  3. Plan rollback if necessary
  4. Monitor system closely

### P2 - Medium (Non-Critical Issues)

- **Response Time**: < 1 hour
- **Actions**:
  1. Document issue
  2. Plan fix for next maintenance window
  3. Monitor for escalation
```

### Automated Incident Detection

```python
#!/usr/bin/env python3
# scripts/incident_detector.py

import psycopg2
import time
import requests
import logging
from datetime import datetime, timedelta

class IncidentDetector:
    def __init__(self, db_config, alert_webhook):
        self.db_config = db_config
        self.alert_webhook = alert_webhook
        self.logger = logging.getLogger(__name__)

    def check_migration_health(self):
        """Check for failed migrations in the last hour"""
        try:
            conn = psycopg2.connect(**self.db_config)
            cursor = conn.cursor()

            one_hour_ago = datetime.now() - timedelta(hours=1)

            cursor.execute("""
                SELECT version, description, success, installed_on
                FROM flyway_schema_history
                WHERE installed_on > %s AND success = false
            """, (one_hour_ago,))

            failed_migrations = cursor.fetchall()

            if failed_migrations:
                self.trigger_incident_alert(
                    'migration_failure',
                    f"Failed migrations detected: {failed_migrations}"
                )

            cursor.close()
            conn.close()

        except Exception as e:
            self.logger.error(f"Health check failed: {e}")

    def check_performance_metrics(self):
        """Check for performance degradation"""
        try:
            conn = psycopg2.connect(**self.db_config)
            cursor = conn.cursor()

            # Check for long-running queries
            cursor.execute("""
                SELECT pid, now() - pg_stat_activity.query_start AS duration, query
                FROM pg_stat_activity
                WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes'
                AND state = 'active'
            """)

            long_queries = cursor.fetchall()

            if long_queries:
                self.trigger_incident_alert(
                    'performance_degradation',
                    f"Long-running queries detected: {len(long_queries)} queries"
                )

            cursor.close()
            conn.close()

        except Exception as e:
            self.logger.error(f"Performance check failed: {e}")

    def trigger_incident_alert(self, incident_type, message):
        """Send incident alert to monitoring system"""
        payload = {
            'incident_type': incident_type,
            'message': message,
            'timestamp': datetime.now().isoformat(),
            'severity': 'high' if 'failure' in incident_type else 'medium'
        }

        try:
            response = requests.post(self.alert_webhook, json=payload)
            self.logger.info(f"Alert sent: {response.status_code}")
        except Exception as e:
            self.logger.error(f"Failed to send alert: {e}")

if __name__ == "__main__":
    detector = IncidentDetector(
        db_config={
            'host': 'localhost',
            'database': 'myapp',
            'user': 'monitor_user',
            'password': 'monitor_password'
        },
        alert_webhook='http://alertmanager:9093/api/v1/alerts'
    )

    detector.check_migration_health()
    detector.check_performance_metrics()
```

## Step 5: Dashboard and Reporting

### Grafana Dashboard Configuration

```json
{
  "dashboard": {
    "title": "Database Migration Dashboard",
    "panels": [
      {
        "title": "Migration Success Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(flyway_migrations_total{status=\"success\"}[5m]) / rate(flyway_migrations_total[5m]) * 100"
          }
        ]
      },
      {
        "title": "Migration Duration",
        "type": "graph",
        "targets": [
          {
            "expr": "flyway_migration_duration_seconds"
          }
        ]
      },
      {
        "title": "Schema Validation Status",
        "type": "table",
        "targets": [
          {
            "expr": "flyway_validation_errors_total"
          }
        ]
      }
    ]
  }
}
```

## Verification Tasks

Complete these verification activities:

1. **Monitoring Setup**

   - Deploy monitoring stack
   - Verify metrics collection
   - Test alert notifications

2. **Rollback Procedures**

   - Execute test rollback on staging
   - Verify data preservation
   - Test automatic rollback triggers

3. **Incident Response**
   - Simulate database incident
   - Follow response procedures
   - Document lessons learned

## Best Practices Summary

### Monitoring

- Monitor both technical and business metrics
- Set up proactive alerts, not just reactive ones
- Implement escalation procedures
- Regular testing of monitoring systems

### Rollback Procedures

- Always preserve critical data during rollbacks
- Test rollback procedures regularly
- Automate where possible, but allow manual override
- Document rollback procedures clearly

### Incident Response

- Establish clear severity levels and response times
- Maintain updated contact information
- Conduct post-incident reviews
- Continuously improve procedures

## Troubleshooting

### Monitoring Issues

- Verify database connectivity from monitoring tools
- Check metric collection permissions
- Validate alert rule syntax
- Test notification channels

### Rollback Failures

- Verify backup integrity before rollback
- Check for blocking connections
- Review migration dependencies
- Ensure sufficient disk space

## Next Steps

In Lab 6, you'll learn industry best practices and advanced techniques for database DevOps at scale.

## Additional Resources

- [Database Monitoring Best Practices](https://www.datadoghq.com/blog/database-monitoring-best-practices/)
- [Incident Response for Database Teams](https://response.pagerduty.com/before/different_roles/)
- [Grafana Database Dashboards](https://grafana.com/grafana/dashboards/?search=database)
