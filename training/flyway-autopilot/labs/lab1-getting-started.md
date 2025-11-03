---
layout: single
title: "Lab 1: Getting Started with Flyway Autopilot"
description: "Introduction to Flyway Autopilot and setting up your development environment"
next_lab:
  title: "Lab 2: Pipelines and Automation"
  url: "/database-devops-autopilot/training/flyway-autopilot/labs/lab2-pipelines-and-automation"
---

Welcome to your first lab! In this session, you'll set up your development environment and get familiar with the basics of Flyway Autopilot.

## Learning Objectives

- Understand the fundamentals of database DevOps
- Install and configure Flyway Autopilot
- Create your first migration script
- Explore the Flyway Autopilot dashboard

## Prerequisites

- Docker installed and running
- Git configured on your machine
- Basic SQL knowledge
- Text editor or IDE of your choice

## Step 1: Environment Setup

### Install Flyway Autopilot

```bash
# Download and install Flyway Autopilot
curl -fsSL https://download.redgate.com/flyway/autopilot/install.sh | bash

# Verify installation
flyway-autopilot --version
```

### Configure Your Project

```bash
# Create a new project directory
mkdir my-database-project
cd my-database-project

# Initialize Flyway configuration
flyway-autopilot init
```

## Step 2: Create Your First Migration

Create a new SQL migration file:

```sql
-- V1__Create_users_table.sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Step 3: Run Your Migration

Execute the migration:

```bash
flyway-autopilot migrate
```

## Step 4: Explore the Dashboard

1. Open your browser and navigate to the Flyway Autopilot dashboard
2. Review the migration history
3. Explore the schema visualization

![Dashboard Screenshot](../../../assets/images/labs/lab1-dashboard.png)

## Verification

Verify that your migration was successful:

```sql
-- Check if the table was created
SELECT * FROM information_schema.tables WHERE table_name = 'users';

-- Insert test data
INSERT INTO users (username, email) VALUES ('testuser', 'test@example.com');

-- Verify the data
SELECT * FROM users;
```

## Key Takeaways

- Flyway Autopilot automates database schema changes
- Migration scripts follow a versioning convention
- The dashboard provides visibility into migration status
- All changes are tracked and auditable

## Next Steps

In the next lab, you'll learn how to integrate Flyway Autopilot with CI/CD pipelines for automated deployments.

## Troubleshooting

### Common Issues

**Connection Error**: Ensure your database is running and connection parameters are correct.

**Permission Denied**: Check that your database user has the necessary privileges.

**Migration Failed**: Review the error logs and ensure your SQL syntax is correct.

## Additional Resources

- [Flyway Autopilot Documentation](https://documentation.red-gate.com/flyway)
- [SQL Migration Best Practices](https://flywaydb.org/documentation/concepts/migrations)
- [Database DevOps Guide](https://www.red-gate.com/database-devops)
