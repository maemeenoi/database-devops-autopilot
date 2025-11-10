# Flyway Configuration Guide

This project uses **two different Flyway configuration files** for different purposes:

## 🔧 For Local Development (Flyway Desktop)

**File:** `flyway-local.toml` (template)

1. **Copy the template:**

   ```bash
   cp flyway-local.toml flyway-local-configured.toml
   ```

2. **Edit `flyway-local-configured.toml` with your actual credentials:**

   ```toml
   [environments.development]
   url = "jdbc:sqlserver://myserver.database.windows.net:1433;databaseName=MyDevDB;encrypt=true;trustServerCertificate=false"
   user = "myusername@mycompany.com"
   password = "MySecurePassword123!"
   ```

3. **Use in Flyway Desktop or CLI:**
   ```bash
   flyway -configFiles=flyway-local-configured.toml info
   flyway -configFiles=flyway-local-configured.toml migrate
   ```

## 🚀 For CI/CD Pipeline (GitHub Actions)

**File:** `flyway.toml` (current file)

- Uses `${env.VARIABLE_NAME}` syntax
- Environment variables provided by GitHub Secrets
- No hardcoded credentials - safe to commit
- Automatically used by GitHub Actions workflow

### Required GitHub Secrets:

- `AZURE_SQL_SERVER` - Your Azure SQL Server name
- `AZURE_SQL_USER` - Your Azure SQL username
- `AZURE_SQL_PASSWORD` - Your Azure SQL password
- `FLYWAY_DEV_DATABASE` - Development database name
- `FLYWAY_UAT_DATABASE` - UAT database name

## 🛡️ Security

- ✅ `flyway.toml` - Safe to commit (no credentials)
- ✅ `flyway-local.toml` - Safe to commit (template only)
- ❌ `flyway-local-configured.toml` - Contains credentials, excluded by `.gitignore`

## 🔄 Workflow

1. **Development:** Use `flyway-local-configured.toml` with Flyway Desktop
2. **CI/CD:** GitHub Actions automatically uses `flyway.toml` with secrets
3. **Both configurations** point to the same migration files in `/migrations/`
