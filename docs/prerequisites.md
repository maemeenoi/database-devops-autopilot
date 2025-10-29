# Prerequisites

## System Requirements

### Hardware Requirements

**Minimum Specifications:**

- 8 GB RAM
- 50 GB available disk space
- 2 CPU cores
- Stable internet connection

**Recommended Specifications:**

- 16 GB RAM or more
- 100 GB available disk space
- 4 CPU cores or more
- High-speed internet connection

### Operating System Support

This workshop supports the following operating systems:

- **Windows 10/11** (Professional or Enterprise)
- **macOS 10.15** or later
- **Linux distributions**: Ubuntu 20.04+, CentOS 8+, RHEL 8+, Amazon Linux 2

## Required Software

### Core Development Tools

#### 1. Docker Desktop

**Purpose**: Container runtime for database and application services

**Installation:**

- **Windows/macOS**: Download from [docker.com](https://www.docker.com/products/docker-desktop)
- **Linux**: Follow [Docker installation guide](https://docs.docker.com/engine/install/)

**Verification:**

```bash
docker --version
docker-compose --version
```

#### 2. Git

**Purpose**: Version control for database migrations and collaboration

**Installation:**

- **Windows**: Download from [git-scm.com](https://git-scm.com/download/win)
- **macOS**: Install via Homebrew: `brew install git`
- **Linux**: Use package manager: `sudo apt install git` (Ubuntu) or `sudo yum install git` (CentOS)

**Configuration:**

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"
```

#### 3. Database Client Tools

**PostgreSQL Client (psql)**

- **Windows**: Download from [PostgreSQL Downloads](https://www.postgresql.org/download/windows/)
- **macOS**: Install via Homebrew: `brew install postgresql`
- **Linux**: Use package manager: `sudo apt install postgresql-client`

**Verification:**

```bash
psql --version
```

### Development Environment

#### 1. Code Editor

Choose one of the following:

**Visual Studio Code (Recommended)**

- Download from [code.visualstudio.com](https://code.visualstudio.com/)
- Install recommended extensions:
  - SQL Tools
  - Docker
  - GitLens
  - YAML

**Alternative Options:**

- IntelliJ IDEA (with Database Tools plugin)
- Sublime Text (with SQL syntax highlighting)
- Vim/Emacs (with appropriate plugins)

#### 2. Terminal/Command Line

- **Windows**: PowerShell 5.1+ or Windows Terminal
- **macOS**: Terminal.app or iTerm2
- **Linux**: Bash shell

## Workshop-Specific Tools

### Flyway Community Edition

**Purpose**: Database migration tool (Community Edition is sufficient for this workshop)

**Installation:**

```bash
# Download and install Flyway
wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/9.22.3/flyway-commandline-9.22.3-linux-x64.tar.gz
tar -xzf flyway-commandline-9.22.3-linux-x64.tar.gz
sudo mv flyway-9.22.3 /opt/flyway
sudo ln -s /opt/flyway/flyway /usr/local/bin/flyway
```

**Verification:**

```bash
flyway --version
```

## Network and Security Requirements

### Network Access

Ensure your environment allows outbound connections to:

- **Docker Hub**: `hub.docker.com` (port 443)
- **GitHub**: `github.com` (port 443)
- **Package Repositories**: Various (ports 80, 443)
- **Database Ports**: 5432 (PostgreSQL), 3306 (MySQL), 1433 (SQL Server)

### Firewall Configuration

Configure your firewall to allow:

- Docker container communication
- Local development server access (ports 3000-8080)
- Database client connections

### Corporate Environment Considerations

If working in a corporate environment:

- **Proxy Settings**: Configure tools to work with corporate proxy
- **Certificate Authority**: Install corporate CA certificates if required
- **Security Policies**: Ensure Docker and database tools are approved
- **VPN Access**: May be required for cloud platform access

## Getting Help

### Pre-Workshop Support

If you encounter issues during setup:

1. **Check Documentation**: Review the official documentation for each tool
