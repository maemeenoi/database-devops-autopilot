---
layout: single
title: "Lab 4: Version Control"
description: "Advanced database version management and team collaboration strategies"
toc: true
toc_label: "Lab Steps"
toc_icon: "tasks"
prev_lab:
  title: "Lab 3: Deployments"
  url: "/database-devops-autopilot/training/flyway-autopilot/labs/lab3-deployments"
next_lab:
  title: "Lab 5: Monitoring and Rollback"
  url: "/database-devops-autopilot/training/flyway-autopilot/labs/lab5-monitoring-and-rollback"
---

# Lab 4: Version Control

Master database version control strategies for team collaboration, branching workflows, and maintaining schema consistency across environments.

## Learning Objectives

- Implement Git-based database version control
- Handle merge conflicts in schema changes
- Set up branch-specific database environments
- Manage collaborative development workflows

## Prerequisites

- Completed Labs 1-3
- Git proficiency
- Understanding of branching strategies
- Access to team development environment

## Step 1: Git Workflow Setup

### Repository Structure

```
database-project/
├── migrations/
│   ├── V001__Initial_schema.sql
│   ├── V002__Add_users_table.sql
│   └── V003__Add_user_preferences.sql
├── seeds/
│   ├── dev/
│   │   └── sample_data.sql
│   └── test/
│       └── test_data.sql
├── scripts/
│   ├── deployment/
│   └── utilities/
├── docs/
│   └── schema_design.md
└── .flyway/
    ├── flyway.toml
    └── environments/
        ├── dev.toml
        ├── staging.toml
        └── prod.toml
```

### Git Hooks for Database Changes

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Validate SQL syntax before commit

echo "Validating SQL files..."

# Find all SQL files in the commit
SQL_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sql$')

if [ -z "$SQL_FILES" ]; then
    echo "No SQL files to validate."
    exit 0
fi

# Validate each SQL file
for file in $SQL_FILES; do
    echo "Validating $file..."

    # Check SQL syntax using psql
    if ! psql -d template1 -f "$file" --set ON_ERROR_STOP=1 --quiet --dry-run; then
        echo "SQL validation failed for $file"
        exit 1
    fi
done

echo "All SQL files validated successfully."
```

## Step 2: Branch-Based Development

### Feature Branch Workflow

```bash
# Create feature branch for database changes
git checkout -b feature/user-authentication

# Create migration for new feature
cat > migrations/V004__Add_authentication.sql << EOF
-- Add authentication columns to users table
ALTER TABLE users ADD COLUMN password_hash VARCHAR(255);
ALTER TABLE users ADD COLUMN last_login TIMESTAMP;
ALTER TABLE users ADD COLUMN failed_login_attempts INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN account_locked_until TIMESTAMP;

-- Create sessions table
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_sessions_token ON user_sessions(token_hash);
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
EOF

# Test migration on feature branch database
flyway migrate -environment=feature-user-auth
```

### Environment Configuration for Branches

```toml
# .flyway/environments/feature-user-auth.toml
[environments.feature-user-auth]
url = "jdbc:postgresql://localhost:5432/myapp_feature_user_auth"
user = "dev_user"
password = "${DB_PASSWORD}"
schemas = ["public"]
jarDirs = []

[environments.feature-user-auth.flyway]
locations = ["filesystem:migrations"]
validateOnMigrate = true
cleanDisabled = false
```

## Step 3: Handling Merge Conflicts

### Conflict Resolution Strategy

When multiple developers create migrations simultaneously:

```bash
# Developer A creates V005__Add_roles.sql
# Developer B creates V005__Add_audit_log.sql

# During merge, conflicts arise in version numbers
git merge feature/audit-logging
# Conflict in migration versions detected
```

### Automated Version Resolution

Create `scripts/resolve-migration-conflicts.sh`:

```bash
#!/bin/bash
# Automatically resolve migration version conflicts

echo "Resolving migration version conflicts..."

# Find conflicting migration files
CONFLICTS=$(find migrations/ -name "V*.sql" | sort -V | awk -F'V' '{print $2}' | awk -F'__' '{print $1}' | uniq -d)

if [ -z "$CONFLICTS" ]; then
    echo "No version conflicts found."
    exit 0
fi

echo "Found version conflicts: $CONFLICTS"

# Get the highest existing version
HIGHEST_VERSION=$(find migrations/ -name "V*.sql" | sed 's/.*V\([0-9]*\)__.*/\1/' | sort -n | tail -1)
NEXT_VERSION=$((HIGHEST_VERSION + 1))

# Rename conflicting files
for file in migrations/V$CONFLICTS__*.sql; do
    if [ -f "$file" ]; then
        NEW_NAME=$(echo "$file" | sed "s/V$CONFLICTS__/V$(printf "%03d" $NEXT_VERSION)__/")
        echo "Renaming $file to $NEW_NAME"
        git mv "$file" "$NEW_NAME"
        NEXT_VERSION=$((NEXT_VERSION + 1))
    fi
done

echo "Version conflicts resolved."
```

## Step 4: Collaborative Development Patterns

### Schema Review Process

Create `.github/pull_request_template.md`:

```markdown
## Database Changes

### Migration Summary

- [ ] This PR includes database migrations
- [ ] Backward compatibility maintained
- [ ] Data migration strategy documented
- [ ] Rollback procedure tested

### Schema Changes

Describe the database changes in this PR:

### Testing

- [ ] Migration tested on development environment
- [ ] Performance impact assessed
- [ ] Rollback tested successfully

### Deployment Notes

Any special considerations for deployment:

### Database Reviewer

@database-team
```

### Automated Schema Validation

Create `.github/workflows/schema-validation.yml`:

```yaml
name: Schema Validation

on:
  pull_request:
    paths:
      - "migrations/**"
      - ".flyway/**"

jobs:
  validate-schema:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Setup Flyway
        run: |
          wget -qO- https://download.redgate.com/maven/release/org/flywaydb/flyway-commandline/8.5.13/flyway-commandline-8.5.13-linux-x64.tar.gz | tar xvz
          sudo ln -s `pwd`/flyway-8.5.13/flyway /usr/local/bin

      - name: Run Migration Tests
        run: |
          # Test baseline migration
          flyway -url=jdbc:postgresql://localhost:5432/test_db -user=postgres -password=postgres migrate

          # Validate schema state
          flyway -url=jdbc:postgresql://localhost:5432/test_db -user=postgres -password=postgres validate

          # Test rollback if undo migrations exist
          if ls migrations/U*.sql 1> /dev/null 2>&1; then
            flyway -url=jdbc:postgresql://localhost:5432/test_db -user=postgres -password=postgres undo
          fi
```

## Step 5: Team Synchronization

### Daily Schema Sync

Create `scripts/sync-team-schema.sh`:

```bash
#!/bin/bash
# Synchronize team member's local database with latest schema

echo "Synchronizing local database with team schema..."

# Pull latest changes
git pull origin main

# Check if there are new migrations
NEW_MIGRATIONS=$(git diff HEAD@{1} --name-only | grep "migrations/.*\.sql$" || true)

if [ -n "$NEW_MIGRATIONS" ]; then
    echo "New migrations detected:"
    echo "$NEW_MIGRATIONS"

    # Apply new migrations
    flyway migrate -environment=dev

    echo "Database synchronized successfully."
else
    echo "No new migrations to apply."
fi

# Update seed data if changed
if git diff HEAD@{1} --name-only | grep -q "seeds/"; then
    echo "Updating seed data..."
    psql -d myapp_dev -f seeds/dev/sample_data.sql
fi
```

### Schema Drift Detection

Create `scripts/detect-schema-drift.sh`:

```bash
#!/bin/bash
# Detect if local database schema differs from expected state

echo "Checking for schema drift..."

# Generate current schema
pg_dump -d myapp_dev --schema-only --no-owner --no-privileges > temp_current_schema.sql

# Apply migrations to clean database and generate expected schema
createdb temp_expected_db
flyway migrate -url=jdbc:postgresql://localhost:5432/temp_expected_db -user=$USER
pg_dump -d temp_expected_db --schema-only --no-owner --no-privileges > temp_expected_schema.sql

# Compare schemas
if diff -u temp_expected_schema.sql temp_current_schema.sql > schema_diff.txt; then
    echo "No schema drift detected."
    rm -f temp_*.sql schema_diff.txt
else
    echo "Schema drift detected! See schema_diff.txt for details."
    cat schema_diff.txt
fi

# Cleanup
dropdb temp_expected_db
```

## Verification Activities

Complete these verification steps:

1. **Branch Workflow Test**

   - Create feature branch with database changes
   - Test migration in isolated environment
   - Merge without conflicts

2. **Conflict Resolution**

   - Simulate version conflicts
   - Use automated resolution script
   - Verify proper version sequencing

3. **Team Collaboration**
   - Submit PR with database changes
   - Complete schema review process
   - Test synchronization scripts

## Best Practices Checklist

### Version Control

- [ ] Use semantic versioning for migrations
- [ ] Include descriptive migration names
- [ ] Maintain linear migration history
- [ ] Document breaking changes

### Team Collaboration

- [ ] Implement mandatory schema reviews
- [ ] Use automated validation in CI/CD
- [ ] Maintain up-to-date documentation
- [ ] Regular team schema sync meetings

### Conflict Prevention

- [ ] Communicate database changes early
- [ ] Use feature flags for risky changes
- [ ] Implement automated conflict detection
- [ ] Plan migration sequencing

## Troubleshooting

### Common Issues

**Migration Version Conflicts**

- Use automated resolution script
- Coordinate with team on version numbers
- Implement sequential assignment process

**Schema Drift**

- Run drift detection regularly
- Investigate unauthorized changes
- Restore from known good state if needed

**Merge Conflicts in Migrations**

- Never edit committed migrations
- Create new migrations for fixes
- Use proper conflict resolution workflow

## Next Steps

In Lab 5, you'll implement comprehensive monitoring and establish robust rollback procedures for production deployments.

## Additional Resources

- [Database Version Control Best Practices](https://www.red-gate.com/simple-talk/databases/database-administration/database-version-control-best-practices/)
- [Git Workflows for Database Teams](https://about.gitlab.com/topics/version-control/database-version-control/)
- [Schema Migration Strategies](https://martinfowler.com/articles/evodb.html)
