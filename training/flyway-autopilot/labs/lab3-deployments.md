---
layout: lab
title: "Lab 3: Deployments"
description: "Advanced deployment strategies and handling complex migration scenarios"
prev_lab:
  title: "Lab 2: Pipelines and Automation"
  url: "/training/flyway-autopilot/labs/lab2-pipelines-and-automation/"
next_lab:
  title: "Lab 4: Version Control"
  url: "/training/flyway-autopilot/labs/lab4-version-control/"
---

# Lab 3: Deployments

Learn advanced deployment strategies for complex database scenarios including blue-green deployments, canary releases, and handling large-scale migrations.

## Learning Objectives

- Implement blue-green deployment strategies
- Configure canary releases for database changes
- Handle large data migrations
- Manage deployment rollbacks

## Prerequisites

- Completed Labs 1 and 2
- Understanding of deployment patterns
- Access to multiple database environments

## Step 1: Blue-Green Deployment Setup

### Infrastructure Configuration

```yaml
# docker-compose.yml for blue-green setup
version: "3.8"
services:
  db-blue:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp_blue
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD: secure_password
    ports:
      - "5432:5432"

  db-green:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp_green
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD: secure_password
    ports:
      - "5433:5432"
```

### Deployment Script

```bash
#!/bin/bash
# blue-green-deploy.sh

CURRENT_ENV=$(cat current_environment.txt)
NEW_ENV="green"

if [ "$CURRENT_ENV" = "green" ]; then
    NEW_ENV="blue"
fi

echo "Deploying to $NEW_ENV environment..."

# Run migrations on the new environment
flyway-autopilot migrate --environment=$NEW_ENV

# Run health checks
if ./health-check.sh $NEW_ENV; then
    echo "Health checks passed. Switching traffic to $NEW_ENV"
    echo $NEW_ENV > current_environment.txt
    ./switch-traffic.sh $NEW_ENV
else
    echo "Health checks failed. Keeping traffic on $CURRENT_ENV"
    exit 1
fi
```

## Step 2: Canary Deployment Configuration

### Gradual Migration Strategy

```sql
-- V3__Add_email_verification.sql
-- Canary deployment: Add column without constraints first
ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT FALSE;

-- Update existing users gradually
UPDATE users
SET email_verified = TRUE
WHERE created_at < NOW() - INTERVAL '30 days'
AND id % 10 = 0; -- Process 10% of users initially
```

### Monitoring Canary Deployment

```yaml
# canary-monitoring.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: canary-config
data:
  canary_percentage: "10"
  success_threshold: "99.9"
  error_threshold: "0.1"
```

## Step 3: Large Data Migration Strategies

### Chunked Migration Approach

```sql
-- V4__Migrate_large_dataset.sql
-- Create new optimized table structure
CREATE TABLE user_profiles_new (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    profile_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for performance
CREATE INDEX idx_user_profiles_new_user_id ON user_profiles_new(user_id);
```

### Migration Script with Progress Tracking

```bash
#!/bin/bash
# migrate-large-dataset.sh

BATCH_SIZE=1000
TOTAL_RECORDS=$(psql -t -c "SELECT COUNT(*) FROM user_profiles_old;")
PROCESSED=0

echo "Migrating $TOTAL_RECORDS records in batches of $BATCH_SIZE"

while [ $PROCESSED -lt $TOTAL_RECORDS ]; do
    psql -c "
        INSERT INTO user_profiles_new (user_id, profile_data, created_at)
        SELECT user_id, profile_data, created_at
        FROM user_profiles_old
        WHERE id > $PROCESSED
        ORDER BY id
        LIMIT $BATCH_SIZE;
    "

    PROCESSED=$((PROCESSED + BATCH_SIZE))
    PERCENTAGE=$((PROCESSED * 100 / TOTAL_RECORDS))
    echo "Progress: $PERCENTAGE% ($PROCESSED/$TOTAL_RECORDS)"

    # Small delay to prevent overwhelming the database
    sleep 1
done

echo "Migration completed successfully!"
```

## Step 4: Deployment Validation

### Automated Testing Suite

```sql
-- test-migration.sql
-- Validate data integrity after migration
DO $$
DECLARE
    old_count INTEGER;
    new_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO old_count FROM user_profiles_old;
    SELECT COUNT(*) INTO new_count FROM user_profiles_new;

    IF old_count != new_count THEN
        RAISE EXCEPTION 'Data migration failed: count mismatch (old: %, new: %)',
            old_count, new_count;
    END IF;

    RAISE NOTICE 'Migration validation passed: % records migrated successfully', new_count;
END $$;
```

### Performance Validation

```bash
#!/bin/bash
# performance-test.sh

echo "Running performance tests..."

# Test query performance on new structure
QUERY_TIME=$(psql -t -c "\timing on; SELECT COUNT(*) FROM user_profiles_new WHERE user_id = 1000; \timing off;" 2>&1 | grep "Time:")

echo "Query performance: $QUERY_TIME"

# Set performance threshold (e.g., 100ms)
if [[ $QUERY_TIME =~ ([0-9.]+) ]]; then
    TIME_MS=${BASH_REMATCH[1]}
    if (( $(echo "$TIME_MS > 100" | bc -l) )); then
        echo "Performance test failed: Query took ${TIME_MS}ms (threshold: 100ms)"
        exit 1
    fi
fi

echo "Performance test passed!"
```

## Step 5: Rollback Procedures

### Automated Rollback Script

```bash
#!/bin/bash
# rollback-deployment.sh

ROLLBACK_VERSION=$1

if [ -z "$ROLLBACK_VERSION" ]; then
    echo "Usage: $0 <version_to_rollback_to>"
    echo "Available versions:"
    flyway-autopilot info
    exit 1
fi

echo "Rolling back to version $ROLLBACK_VERSION..."

# Create backup before rollback
./create-backup.sh "pre-rollback-$(date +%Y%m%d_%H%M%S)"

# Perform rollback
flyway-autopilot undo --target=$ROLLBACK_VERSION

# Verify rollback
if ./verify-rollback.sh $ROLLBACK_VERSION; then
    echo "Rollback completed successfully"
else
    echo "Rollback failed. Please investigate immediately."
    exit 1
fi
```

### Rollback Verification

```sql
-- verify-rollback.sql
-- Check that specific schema changes have been reverted
DO $$
BEGIN
    -- Verify that new column doesn't exist
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'users' AND column_name = 'email_verified'
    ) THEN
        RAISE EXCEPTION 'Rollback failed: email_verified column still exists';
    END IF;

    RAISE NOTICE 'Rollback verification passed';
END $$;
```

## Verification Checklist

After completing this lab, verify:

- [ ] Blue-green deployment infrastructure is functional
- [ ] Canary deployment monitoring is in place
- [ ] Large data migration completes successfully
- [ ] Performance tests pass
- [ ] Rollback procedures work correctly
- [ ] All deployment strategies are documented

## Best Practices Summary

### Deployment Safety

- Always test in staging environment first
- Implement automated rollback triggers
- Monitor application metrics during deployment
- Use feature flags for risky changes

### Performance Optimization

- Plan for peak load during migrations
- Use connection pooling for large operations
- Implement proper indexing strategies
- Monitor database performance metrics

### Risk Mitigation

- Create database backups before deployments
- Implement circuit breakers for external dependencies
- Use blue-green deployments for zero-downtime updates
- Maintain deployment runbooks

## Troubleshooting Guide

### Deployment Failures

1. Check database connectivity and permissions
2. Verify migration script syntax
3. Review resource utilization (CPU, memory, disk)
4. Examine application logs for errors

### Performance Issues

1. Analyze query execution plans
2. Check for blocking locks
3. Monitor index usage
4. Review connection pool settings

## Next Steps

In Lab 4, you'll learn advanced version control strategies for managing database schemas across multiple development teams.

## Additional Resources

- [Blue-Green Deployment Patterns](https://martinfowler.com/bliki/BlueGreenDeployment.html)
- [Canary Release Best Practices](https://cloud.google.com/deployment-manager/docs/deployments/canary-deployments)
- [Database Migration Strategies](https://www.redgate.com/database-migrations)
