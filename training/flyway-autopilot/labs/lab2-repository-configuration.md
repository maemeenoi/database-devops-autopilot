---
layout: splash
title: "Lab 2: Repository Configuration"
description: "Flyway project setup and Git integration for version control"
toc: true
toc_label: "Lab Steps"
toc_icon: "tasks"
prev_lab:
  title: "Lab 1: Environment Setup"
  url: "/database-devops-autopilot/training/flyway-autopilot/labs/lab1-environment-setup"
next_lab:
  title: "Lab 3: Database Provisioning"
  url: "/database-devops-autopilot/training/flyway-autopilot/labs/lab3-database-provisioning"
---

## Overview

In this lab, you'll clone the official Database DevOps AutoPilot training repository and set it up with Flyway Desktop for AutoPilot functionality. This repository contains a complete e-commerce platform example with migrations, schema models, and CI/CD pipelines.

## Learning Objectives

- Clone the official training repository from GitHub
- Connect the repository to Flyway Desktop
- Understand the project structure and configuration
- Configure environment variables for Azure SQL Database
- Handle initial setup and connection configuration

## Prerequisites

- Completed Lab 1 (Flyway Desktop Enterprise installed with 28-day trial)
- Git 2.30+ installed and configured
- Access to Azure SQL Database (provided in training)
- GitHub account (optional, for forking)

## Step 1: Clone the Training Repository

### 1. Clone the Repository

Choose one of the following approaches:

#### Option A: Direct Clone (Recommended for Training)

```bash
# Clone the repository to your local machine
git clone https://github.com/LetsMakeStuffGo/database-devops-autopilot.git

# Navigate to the project directory
cd database-devops-autopilot

# Verify the repository structure
ls -la
```

### 2. Explore the Repository Structure

After cloning, explore what you've downloaded:

```bash
# View the main directory structure
tree -L 2
# or use: ls -la
```

You should see a structure like this:

```
database-devops-autopilot/
├── README.md                          # Project documentation
├── flyway.toml                        # Main Flyway configuration (CI/CD)
├── 1.flyway-local.toml                # Local development configuration
├── 2.flyway-pipeline.toml             # Pipeline-specific configuration
├── migrations/                        # Database migration scripts
│   ├── B001__baseline.sql             # E-commerce platform baseline
│   ├── V002__Welcome.sql              # Welcome migration
│   ├── V003__Add_Customer_Loyalty.sql # Customer loyalty features
│   └── V004__Enhanced_Product_Catalog.sql # Product reviews system
├── Scripts/                           # Database setup scripts
│   ├── CreateAutopilotDatabases.sql   # Database creation script
│   └── SetupSchemas.sql               # Schema setup script
├── Reports/                           # Migration reports output
├── schema-model/                      # Schema model files
│   ├── Security/Schemas/              # Schema definitions
│   ├── Stored Procedures/             # Stored procedure definitions
│   ├── Tables/                        # Table definitions
│   └── Views/                         # View definitions
├── .github/workflows/                 # GitHub Actions CI/CD pipelines
├── AzureDevOps/                       # Azure DevOps pipeline templates
└── training/                          # Training materials and labs
    └── flyway-autopilot/
        └── labs/                      # Lab instructions (this file!)
```

### 3. Understanding the Repository Components

This repository contains everything you need for Database DevOps with Flyway AutoPilot:

**🗄️ Database Components:**

- **E-commerce platform** with customers, products, orders, and loyalty program
- **Sample data** from international customers and real products
- **Business intelligence views** for analytics and reporting
- **Stored procedures** for business operations

**🔧 DevOps Components:**

- **Multiple Flyway configurations** for different environments
- **CI/CD pipeline templates** for GitHub Actions and Azure DevOps
- **Schema model** for change tracking and collaboration
- **Migration reports** for deployment validation

**📚 Training Materials:**

- **Step-by-step labs** for hands-on learning
- **Documentation and guides** for best practices
- **Reference implementations** following Redgate patterns
- Git 2.30+ installed

## Step 2: Review Flyway Configuration

### 1. Understanding the Two Configuration Files

The repository contains two main Flyway configuration files for different use cases:

#### Configuration 1: Local Development (Flyway Desktop)

**File: `1.flyway-local.toml`** - Used for local development and Flyway Desktop

```toml
id = "database-devops-autopilot-local"
name = "Database DevOps AutoPilot (Local Development)"
databaseType = "SqlServer"

[environments.development]
url = "jdbc:sqlserver://sqlbits.database.windows.net:1433;databaseName=db-autopilot-dev-001;encrypt=true;trustServerCertificate=false"
user = "sqladmin"
password = "YourActualPassword"
displayName = "Development Database"

[environments.shadow]
url = "jdbc:sqlserver://sqlbits.database.windows.net:1433;databaseName=db-autopilot-shadow-001;encrypt=true;trustServerCertificate=false"
user = "sqladmin"
password = "YourActualPassword"
displayName = "Shadow Database (Validation)"
provisioner = "clean"

[environments.uat]
url = "jdbc:sqlserver://sqlbits.database.windows.net:1433;databaseName=db-autopilot-uat-001;encrypt=true;trustServerCertificate=false"
user = "sqladmin"
password = "YourActualPassword"
displayName = "UAT Database"

[flyway]
locations = [ "filesystem:migrations" ]
mixed = true
outOfOrder = true
validateMigrationNaming = true
defaultSchema = "Customers"
baselineOnMigrate = true
baselineVersion = "001"
errorOverrides = [ "S0001:0:I-" ]

[flywayDesktop]
developmentEnvironment = "development"
shadowEnvironment = "shadow"
schemaModel = "./schema-model"

[flywayDesktop.generate]
undoScripts = true
```

**✅ Use this configuration for:**
- **Flyway Desktop** development and testing
- **Local command line** Flyway operations
- **Training exercises** and hands-on labs
- **Quick database connections** without environment setup

#### Configuration 2: CI/CD Pipelines (Production)

**File: `flyway.toml`** - Used for CI/CD pipelines and production deployments

```toml
id = "database-devops-autopilot-training"
name = "Database DevOps AutoPilot Training"
databaseType = "SqlServer"

[environments.development]
url = "jdbc:sqlserver://${env.AZURE_SQL_SERVER}.database.windows.net:1433;databaseName=${env.FLYWAY_DEV_DATABASE};encrypt=true;trustServerCertificate=false"
user = "${env.AZURE_SQL_USER}"
password = "${env.AZURE_SQL_PASSWORD}"
displayName = "Development database"
provisioner = "clean"

[environments.shadow]
url = "jdbc:sqlserver://${env.AZURE_SQL_SERVER}.database.windows.net:1433;databaseName=${env.FLYWAY_SHADOW_DATABASE};encrypt=true;trustServerCertificate=false"
user = "${env.AZURE_SQL_USER}"
password = "${env.AZURE_SQL_PASSWORD}"
displayName = "Shadow database (validation)"
provisioner = "clean"

[environments.uat]
url = "jdbc:sqlserver://${env.AZURE_SQL_SERVER}.database.windows.net:1433;databaseName=${env.FLYWAY_UAT_DATABASE};encrypt=true;trustServerCertificate=false"
user = "${env.AZURE_SQL_USER}"
password = "${env.AZURE_SQL_PASSWORD}"
displayName = "UAT (User Acceptance Testing) database"

[environments.production]
url = "jdbc:sqlserver://${env.AZURE_SQL_SERVER}.database.windows.net:1433;databaseName=${env.FLYWAY_PROD_DATABASE};encrypt=true;trustServerCertificate=false"
user = "${env.AZURE_SQL_USER}"
password = "${env.AZURE_SQL_PASSWORD}"
displayName = "Production database"

[flyway]
locations = [ "filesystem:migrations" ]
mixed = true
outOfOrder = true
validateMigrationNaming = true
defaultSchema = "Customers"
baselineOnMigrate = true
baselineVersion = "001"
errorOverrides = [ "S0001:0:I-" ]

[flywayDesktop]
developmentEnvironment = "development"
shadowEnvironment = "shadow"
schemaModel = "./schema-model"

[flywayDesktop.generate]
undoScripts = true
```

**🚀 Use this configuration for:**
- **GitHub Actions** workflows
- **Azure DevOps** pipelines
- **Production deployments**
- **Environment variable** based credential management
- **Team collaboration** with secure secrets

### 2. Configuration Comparison

| Feature | Local Development (`1.flyway-local.toml`) | CI/CD Pipeline (`flyway.toml`) |
|---------|-------------------------------------------|--------------------------------|
| **Primary Use** | Flyway Desktop & Local Development | GitHub Actions & Azure DevOps |
| **Credentials** | Hardcoded (training convenience) | Environment Variables (secure) |
| **Environments** | 3 (dev, shadow, uat) | 4 (dev, shadow, uat, production) |
| **Security** | ⚠️ Training only | ✅ Production ready |
| **Team Sharing** | ❌ Contains passwords | ✅ Uses secrets |
| **Best For** | Learning & Development | Production Deployment |

> **For this training**, we'll use `1.flyway-local.toml` with Flyway Desktop for hands-on learning, then explore `flyway.toml` to understand production patterns.

> **Note**: This configuration uses Azure SQL Database with environment variables for secure credential management. The environment variables (${env.VARIABLE_NAME}) are resolved at runtime from:
>
> - GitHub Secrets (in CI/CD pipelines)
> - Local environment variables (for local development)
> - Flyway Desktop credential management

### 2. Review the Repository Structure

Your repository already contains all the necessary files and directories for Flyway AutoPilot:

```
database-devops-autopilot/
├── flyway.toml                    # Main Flyway configuration
├── migrations/                    # Database migration scripts
│   ├── B001__baseline.sql         # Baseline migration
│   ├── V002__Welcome.sql          # Sample versioned migration
│   ├── V003__Add_Customer_Loyalty.sql     # Customer loyalty features
│   ├── V004__Enhanced_Product_Catalog.sql # Product catalog enhancements
│   ├── U002__UNDO-Welcome.sql     # Undo script for V002
│   ├── U003__UNDO-Add_Customer_Loyalty.sql # Undo script for V003
│   └── U004__UNDO-Enhanced_Product_Catalog.sql # Undo script for V004
├── Scripts/                       # Database setup scripts
│   └── CreateAutopilotDatabases.sql
├── Reports/                       # Migration reports output
├── schema-model/                  # Schema model files
│   ├── Security/Schemas/
│   ├── Stored Procedures/
│   ├── Tables/
│   └── Views/
├── .github/workflows/             # GitHub Actions CI/CD
└── AzureDevOps/                   # Azure DevOps pipelines
```

### 3. Review the Migration Files

The repository already contains the initial migration files for training:

**migrations/B001\_\_baseline.sql** - Baseline migration:

```sql
-- Baseline migration for Flyway AutoPilot Training
-- This establishes the starting point for schema versioning
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Baseline migration completed'
```

**migrations/V002\_\_Welcome.sql** - Welcome migration:

```sql
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Welcome to Flyway AutoPilot Training!'
```

**migrations/V003\_\_Add_Customer_Loyalty.sql** - Customer loyalty features:

```sql
-- 🌟 V003: Customer Loyalty Program Enhancement
-- Adding exciting customer loyalty features to boost engagement!
```

**migrations/V004\_\_Enhanced_Product_Catalog.sql** - Product catalog enhancements:

```sql
-- 🛒 V004: Enhanced Product Catalog
-- Adding product reviews and inventory tracking
```

**Corresponding Undo Scripts:**

- **U002\_\_UNDO-Welcome.sql** - Undo script for V002
- **U003\_\_UNDO-Add_Customer_Loyalty.sql** - Undo script for V003
- **U004\_\_UNDO-Enhanced_Product_Catalog.sql** - Undo script for V004

> **Note**: Additional migration files (V005+) will be created during the hands-on labs to demonstrate the migration workflow.

### 4. Review Database Setup Script

The repository includes `Scripts/CreateAutopilotDatabases.sql` for database provisioning.

```sql
### 4. Review Database Setup Script

The repository includes `Scripts/CreateAutopilotDatabases.sql` for database provisioning. This script will create both training databases (db-autopilot-dev-001 and db-autopilot-uat-001) with all required schemas.

## Step 2: Connect Repository to Flyway Desktop
```

## Step 3: Connect Repository to Flyway Desktop

### 1. Open Project in Flyway Desktop

1. Launch **Flyway Desktop**
2. Click **"Open project..."**
3. Select **"Open from disk"**
4. Navigate to your **cloned repository folder** (`database-devops-autopilot`)
5. Select the **existing** `flyway.toml` file
6. Click **"Open"**

![Find Toml File](../../../assets/images/Find_Toml.png)

> **Note**: You now have a local copy of the complete training repository with all migrations, schema models, and configurations ready for use!

### 2. Handle Expected Connection Error

**Don't panic!** You'll see a connection error - this is expected.

![Expected Database Error](../../../assets/images/labs/lab2-error.png)

**Don't panic, this error is expected.** This is simply because there are no AutoPilot databases to connect to yet. To create these, click on the **blue folder icon** in the upper right to jump to the files on disk.

### Troubleshooting Common Connection Issues

If you encounter a "Flyway Exception: Error encountered migrating development environment" error when trying to migrate to UAT:

1. **Environment Variable Issues**: Ensure all required environment variables are set:

   ```bash
   echo $AZURE_SQL_SERVER
   echo $FLYWAY_UAT_DATABASE
   echo $AZURE_SQL_USER
   # Password should be set but don't echo it for security
   ```

2. **Database Doesn't Exist**: The UAT database might not exist on your Azure SQL Server. Check if the database exists:

   - Connect to your Azure SQL Server using Azure Data Studio or SSMS
   - Verify the database name matches the `FLYWAY_UAT_DATABASE` environment variable

3. **Network/Firewall Issues**: Ensure your IP address is allowed to connect to the Azure SQL Server:

   - Check Azure SQL Server firewall rules
   - Add your current IP address to the allowed list

4. **Authentication Issues**: Verify your credentials are correct:

   - Test connection using Azure Data Studio or SSMS with the same credentials
   - Ensure the user has proper permissions on the target database

5. **Use Local Configuration for Testing**: If environment variables are causing issues, try using the local configuration file:
   ```bash
   flyway -configFiles=1.flyway-local.toml info
   ```

### 3. Explore the Project Structure

Now click the **blue folder icon** in the upper right to jump to the files on disk and explore what you've cloned:

```
database-devops-autopilot/
├── flyway.toml                        # Main Flyway configuration (CI/CD)
├── 1.flyway-local.toml                # Local development configuration
├── 2.flyway-pipeline.toml             # Pipeline-specific configuration
├── migrations/                        # Database migration scripts
│   ├── B001__baseline.sql             # E-commerce platform baseline
│   ├── V002__Welcome.sql              # Welcome migration
│   ├── V003__Add_Customer_Loyalty.sql # Customer loyalty features
│   └── V004__Enhanced_Product_Catalog.sql # Product reviews system
├── Scripts/                           # Database setup scripts
│   └── CreateAutopilotDatabases.sql   # Database creation script
├── Reports/                           # Migration reports output
├── schema-model/                      # Schema model files
│   ├── Security/                      # Schema security objects
│   ├── Stored Procedures/             # Stored procedure definitions
│   ├── Tables/                        # Table definitions
│   └── Views/                         # View definitions
├── .github/workflows/                 # GitHub Actions CI/CD
├── AzureDevOps/                       # Azure DevOps pipelines
└── training/flyway-autopilot/         # Training materials (including these labs!)
```

This is a complete, production-ready Database DevOps repository that demonstrates:

- **Multi-environment configuration** (development, shadow, UAT, production)
- **CI/CD pipeline integration** (GitHub Actions + Azure DevOps)
- **Schema model management** for collaboration
- **Real-world e-commerce example** with comprehensive business logic

### 4. Key Configuration Features

The flyway.toml includes important AutoPilot features:

- **Four Environments**: Development, Shadow, UAT, and Production
- **Azure SQL Database**: Cloud-hosted SQL Server instances
- **Environment Variables**: Secure credential management using ${env.VARIABLE_NAME} syntax
- **Shadow Database**: Dedicated environment for schema validation
- **Default Schema**: Set to "Customers"
- **Error Overrides**: Configured for SQL Server best practices
- **Flyway Desktop Integration**: Configured for development environment and schema modeling
- **CI/CD Ready**: Environment variables can be set via GitHub Secrets or local environment

4. Navigate to this repository folder (`database-devops-autopilot`)
5. Select the `flyway.toml` file you just created
6. Click **"Open"**

## Next Steps

Now that you've successfully connected your repository to Flyway Desktop:

1. **Next Lab**: Lab 3 - Provisioning Your Databases

   - You'll use SQL Server Management Studio (SSMS) or your prefeered IDE to provision the databases
   - Follow the official Redgate guidance for database setup
   - Connect your AutoPilot environments to real databases

2. **What You've Accomplished**:
   - ✅ Repository connected to Flyway Desktop
   - ✅ Project structure understood
   - ✅ Configuration reviewed and validated

## Database Environments Overview

Your configuration is ready with these environments (using Azure SQL Database):

| Environment | Purpose                  | Environment Variable   | Example Database Name   |
| ----------- | ------------------------ | ---------------------- | ----------------------- |
| development | Primary development work | FLYWAY_DEV_DATABASE    | db-autopilot-dev-001    |
| shadow      | Schema validation        | FLYWAY_SHADOW_DATABASE | db-autopilot-shadow-001 |
| uat         | User Acceptance Testing  | FLYWAY_UAT_DATABASE    | db-autopilot-uat-001    |
| production  | Production deployment    | FLYWAY_PROD_DATABASE   | db-autopilot-prod-001   |

### Required Environment Variables

For this configuration to work, you need to set the following environment variables:

```bash
# Azure SQL Server Configuration
AZURE_SQL_SERVER=your-server-name          # Without .database.windows.net suffix
AZURE_SQL_USER=your-username
AZURE_SQL_PASSWORD=your-password

# Database Names
FLYWAY_DEV_DATABASE=db-autopilot-dev-001
FLYWAY_SHADOW_DATABASE=db-autopilot-shadow-001
FLYWAY_UAT_DATABASE=db-autopilot-uat-001
FLYWAY_PROD_DATABASE=db-autopilot-prod-001
```

### Local Development Alternative

For local development, the repository also includes `1.flyway-local.toml` with hardcoded credentials for ease of use during training. To use the local configuration:

```bash
flyway -configFiles=1.flyway-local.toml info
```

> **Security Note**: The local configuration file contains hardcoded credentials and should only be used for training purposes. In production, always use environment variables or secure credential management.

### Understanding the Configuration Files

The repository includes multiple Flyway configurations for different scenarios:

| File | Purpose | Usage |
|------|---------|-------|
| `flyway.toml` | CI/CD pipelines | Uses environment variables for secure deployment |
| `1.flyway-local.toml` | Local development | Hardcoded credentials for training convenience |
| `2.flyway-pipeline.toml` | Pipeline-specific | Alternative pipeline configuration |

**For this training**, we'll primarily use:
- **`1.flyway-local.toml`** for quick local development and testing
- **`flyway.toml`** to understand production-ready environment variable patterns

## Reference Materials

This lab uses the official Database DevOps AutoPilot training repository:

- **[Training Repository](https://github.com/LetsMakeStuffGo/database-devops-autopilot)** - Complete source code and examples
- **[Official SQL Server FastTrack](https://github.com/red-gate/Flyway-AutoPilot-FastTrack)** - Reference implementation patterns
- **[Official Repository Setup Guide](https://documentation.red-gate.com/flyway/getting-started-with-flyway/first-steps-flyway-autopilot-a-beginners-guide/flyway-autopilot-fasttrack/2-getting-your-repository-ready)**
- **[Flyway Desktop Documentation](https://documentation.red-gate.com/flyway/getting-started-with-flyway/installers)**

### Repository Structure Reference

The cloned repository follows industry best practices:

**📁 Core Flyway Files:**
- `flyway.toml` - Production configuration with environment variables
- `migrations/` - All database migration scripts in chronological order
- `schema-model/` - Schema model for change detection and collaboration

**🔧 Development Tools:**
- `1.flyway-local.toml` - Local development with training credentials  
- `Scripts/` - Database setup and utility scripts
- `Reports/` - Migration execution reports and validation

**🚀 CI/CD Integration:**
- `.github/workflows/` - GitHub Actions pipeline templates
- `AzureDevOps/` - Azure DevOps pipeline YAML files
- Environment variable patterns for secure deployment

This structure enables:
- **Team collaboration** through schema model version control
- **Multi-environment deployment** with secure credential management  
- **Automated testing** and validation through CI/CD pipelines
- **Production-ready patterns** following Redgate best practices

---

## 🔗 Navigation

**⬅️ [Previous: Lab 1 - Environment Setup](/database-devops-autopilot/training/flyway-autopilot/labs/lab1-environment-setup)** | **🏠 [Workshop Overview](/database-devops-autopilot/training/flyway-autopilot/labs/)** | **➡️ [Next: Lab 3 - Database Provisioning](/database-devops-autopilot/training/flyway-autopilot/labs/lab3-database-provisioning)**

---
