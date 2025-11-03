---
layout: single
title: "Lab 2: Pipelines and Automation"
description: "In this lab, you'll learn how to integrate Flyway Autopilot with CI/CD pipelines to automate your database deployments."
toc: true
toc_label: "Lab Steps"
toc_icon: "tasks"
prev_lab:
  title: "Lab 1: Getting Started"
  url: "/database-devops-autopilot/training/flyway-autopilot/labs/lab1-getting-started"
next_lab:
  title: "Lab 3: Deployments"
  url: "/database-devops-autopilot/training/flyway-autopilot/labs/lab3-deployments"
---

## Learning Objectives

- Set up automated pipeline triggers
- Configure environment-specific deployments
- Implement approval workflows
- Monitor pipeline execution

## Prerequisites

- Completed Lab 1
- Access to a CI/CD platform (GitHub Actions, Azure DevOps, etc.)
- Basic understanding of YAML configuration

## Step 1: Pipeline Configuration

### GitHub Actions Setup

Create `.github/workflows/database-deploy.yml`:

```yaml
name: Database Deployment

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  database-migration:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flyway Autopilot
        run: |
          curl -fsSL https://download.redgate.com/flyway/autopilot/install.sh | bash

      - name: Run Database Migrations
        env:
          DB_URL: ${{ secrets.DATABASE_URL }}
          DB_USER: ${{ secrets.DATABASE_USER }}
          DB_PASSWORD: ${{ secrets.DATABASE_PASSWORD }}
        run: |
          flyway-autopilot migrate
```

### Azure DevOps Pipeline

Create `azure-pipelines.yml`:

```yaml
trigger:
  - main
  - develop

pool:
  vmImage: "ubuntu-latest"

steps:
  - task: FlywayAutopilot@1
    inputs:
      connectionString: $(DatabaseConnectionString)
      migrationsPath: "sql/migrations"
      environment: $(Environment)
```

## Step 2: Environment Configuration

### Development Environment

```yaml
# flyway-dev.conf
flyway.url=jdbc:postgresql://dev-db:5432/myapp
flyway.user=dev_user
flyway.password=${DB_PASSWORD}
flyway.schemas=public
flyway.locations=filesystem:sql/migrations
```

### Production Environment

```yaml
# flyway-prod.conf
flyway.url=jdbc:postgresql://prod-db:5432/myapp
flyway.user=prod_user
flyway.password=${DB_PASSWORD}
flyway.schemas=public
flyway.locations=filesystem:sql/migrations
flyway.validateOnMigrate=true
flyway.cleanDisabled=true
```

## Step 3: Approval Workflows

### Manual Approval for Production

```yaml
production-deployment:
  runs-on: ubuntu-latest
  needs: [test-migration]
  environment: production
  if: github.ref == 'refs/heads/main'

  steps:
    - name: Deploy to Production
      run: |
        flyway-autopilot migrate --environment=production
```

### Review Process Setup

1. Configure environment protection rules
2. Set up required reviewers
3. Define deployment windows

## Step 4: Pipeline Monitoring

### Add Notification Steps

```yaml
- name: Notify on Success
  if: success()
  uses: 8398a7/action-slack@v3
  with:
    status: success
    text: "Database migration completed successfully!"

- name: Notify on Failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    text: "Database migration failed. Please check the logs."
```

### Pipeline Dashboard

![Pipeline Screenshot](../../../assets/images/labs/lab2-pipeline.png)

## Step 5: Testing the Pipeline

1. Create a new migration file
2. Commit and push to trigger the pipeline
3. Monitor execution in your CI/CD platform
4. Verify deployment in target environments

### Sample Migration for Testing

```sql
-- V2__Add_user_preferences.sql
CREATE TABLE user_preferences (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    preference_key VARCHAR(100) NOT NULL,
    preference_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);
```

## Verification

Check that your pipeline:

- Triggers on code changes
- Executes migrations successfully
- Applies proper environment-specific configurations
- Sends appropriate notifications

## Best Practices

### Security

- Store sensitive information in secrets
- Use least-privilege access principles
- Implement environment isolation

### Reliability

- Include rollback procedures
- Test migrations in staging first
- Use database backups before deployments

### Monitoring

- Log all migration activities
- Set up alerts for failures
- Track deployment metrics

## Troubleshooting

### Common Pipeline Issues

**Authentication Failures**: Verify database credentials and network access.

**Migration Conflicts**: Ensure migration order and resolve conflicts before deployment.

**Timeout Issues**: Adjust pipeline timeout settings for large migrations.

## Next Steps

In Lab 3, you'll explore advanced deployment strategies and learn how to handle complex migration scenarios.

## Additional Resources

- [GitHub Actions for Database DevOps](https://github.com/marketplace/actions/flyway-autopilot)
- [Azure DevOps Database Extensions](https://marketplace.visualstudio.com/items?itemName=redgate.flyway-autopilot)
- [CI/CD Best Practices](https://docs.microsoft.com/en-us/azure/devops/learn/what-is-continuous-integration)
