# Flyway Pipeline Comparison: Linux vs macOS

This document outlines the key differences between the Linux and macOS versions of the Flyway CI/CD pipeline.

## Key Differences

### 1. Runner Configuration

- **Linux Pipeline**: Uses `self-hosted` or `ubuntu-latest` runners
- **macOS Pipeline**: Uses `macos-latest` GitHub-hosted runners

### 2. Installation Script

- **Linux Pipeline**: References `Flyway_DownloadAndInstallCLI_Unix.sh`
- **macOS Pipeline**: References `Flyway_DownloadAndInstallCLI_macOS.sh`

### 3. Script Compatibility Issues Fixed in macOS Version

- **BSD grep vs GNU grep**: macOS uses BSD grep which doesn't support `-P` (Perl regex) flag
- **Download method**: macOS version uses `curl` instead of `wget` (which isn't installed by default)
- **Download URL**: Attempts to use macOS-specific Flyway distribution, falls back to Linux version
- **Path handling**: Better handling of macOS-specific paths and shell profiles

### 4. Environment Variables

Both pipelines use the same environment variables:

- `FLYWAY_EMAIL`
- `FLYWAY_TOKEN`
- `FLYWAY_AUTH_DISABLED`
- `TARGET_DATABASE_USERNAME`
- `TARGET_DATABASE_PASSWORD`
- `CUSTOM_PARAMS`

### 5. Pipeline Structure

Both pipelines maintain the same basic structure:

1. **Build Job**: Clean, migrate, and validate database changes
2. **UAT Job**: Deploy to UAT environment with reporting
3. **Artifact Management**: Publish and download build artifacts

## Usage Recommendations

### When to Use Linux Pipeline

- Using Linux-based self-hosted runners
- Docker containerized environments
- Enterprise environments with Linux infrastructure

### When to Use macOS Pipeline

- Local development on macOS
- GitHub-hosted runners for smaller teams
- Mixed development environments
- Quick prototyping and testing

## Setup Instructions

### For Linux Pipeline

1. Set up self-hosted Linux runner or use `ubuntu-latest`
2. Ensure `wget` and GNU grep are available
3. Configure GitHub secrets
4. Enable workflow in repository

### For macOS Pipeline

1. Use GitHub-hosted `macos-latest` runners
2. No additional tool installation required
3. Configure same GitHub secrets as Linux version
4. Enable workflow in repository

## Notes

- Both pipelines can run in parallel if needed
- Environment-specific configurations are maintained in `flyway.toml`
- Database connection details should be stored as GitHub secrets
- Both versions support Flyway Pipelines integration for centralized tracking
