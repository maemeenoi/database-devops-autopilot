---
layout: splash
title: "Database DevOps Autopilot"
header:
  overlay_color: "#000"
  overlay_filter: "0.5"
  actions:
    - label: "Start Training"
      url: "/training/flyway-autopilot/"
      btn_class: "btn--primary btn--large"
excerpt: "Master enterprise-grade database DevOps practices with automated, reliable, and scalable migration pipelines using Flyway."
feature_row:
  - image_path: /assets/images/setup-icon.png
    title: "Quick Setup"
    excerpt: "Get started with Flyway in minutes. Learn project structure, environment configuration, and essential concepts."
    url: "/training/flyway-autopilot/labs/lab1-getting-started"
    btn_label: "Lab 1: Setup"
    btn_class: "btn--primary"
  - image_path: /assets/images/pipeline-icon.png
    title: "CI/CD Integration"
    excerpt: "Automate database deployments with GitHub Actions and Azure DevOps. Build reliable migration pipelines."
    url: "/training/flyway-autopilot/labs/lab2-pipelines-and-automation"
    btn_label: "Lab 2: Pipelines"
    btn_class: "btn--primary"
  - image_path: /assets/images/production-icon.png
    title: "Production Ready"
    excerpt: "Implement zero-downtime deployments, monitoring, rollback strategies, and enterprise-grade safety measures."
    url: "/training/flyway-autopilot/labs/lab6-best-practices"
    btn_label: "Lab 6: Production"
    btn_class: "btn--primary"
---

{% include feature_row %}

## About This Training

Transform your database deployment process from manual, error-prone procedures to automated, reliable, and scalable migration pipelines. This comprehensive workshop teaches you to implement enterprise-grade database DevOps practices using Flyway.

### What You'll Learn

- **Database Version Control**: Integrate schema changes with your application code lifecycle
- **Automated Migrations**: Build and deploy database changes through CI/CD pipelines
- **Production Safety**: Implement rollback strategies, validation checks, and monitoring
- **Team Collaboration**: Support multiple developers working on database changes simultaneously
- **Enterprise Practices**: Apply industry best practices for database DevOps at scale

### Course Format

- **Duration**: 3-4 hours total (6 modular labs, 30-45 minutes each)
- **Format**: Self-paced, hands-on exercises with real database scenarios
- **Prerequisites**: Basic SQL knowledge, Git familiarity, access to SQL Server or PostgreSQL
- **Outcome**: Complete CI/CD pipeline for database deployments

### Training Path

1. **[Lab 1: Setup & First Steps](training/flyway-autopilot/labs/lab1-getting-started)** - Environment setup and Flyway basics
2. **[Lab 2: Pipelines & Automation](training/flyway-autopilot/labs/lab2-pipelines-and-automation)** - CI/CD integration fundamentals
3. **[Lab 3: Advanced Deployments](training/flyway-autopilot/labs/lab3-deployments)** - Complex schema changes and validations
4. **[Lab 4: Version Control](training/flyway-autopilot/labs/lab4-version-control)** - Branching strategies and rollback procedures
5. **[Lab 5: Monitoring](training/flyway-autopilot/labs/lab5-monitoring-and-rollback)** - Troubleshooting and performance optimization
6. **[Lab 6: Production](training/flyway-autopilot/labs/lab6-best-practices)** - Enterprise deployment strategies

### Ready to Get Started?

Check the [prerequisites](docs/prerequisites) and begin with [Lab 1: Setup & First Steps](training/flyway-autopilot/labs/lab1-getting-started).

---

## About LetsMakeStuffGo

This training is brought to you by [LetsMakeStuffGo](https://www.makestuffgo.com) - specialists in Cloud and DevOps Engineering practices. We help organizations implement world-class DevOps practices that deliver measurable business value.

**Assess Your DevOps Maturity**: Take our [FREE DevOps & FinOps Assessment](https://assessment.makestuffgo.com) to see how your organization compares to industry standards.

---

## About This Training

{% include feature_row %}

## Database DevOps Autopilot: Flyway Migration Training

This comprehensive workshop is a deep dive into database DevOps automation using Flyway, where you will learn practical techniques for managing database schema changes, version control, and automated deployments. Our exploration begins with foundational CI/CD capabilities for database migrations, ensuring your database changes are versioned, tested, and deployed consistently across all environments.

You'll master enterprise-grade database DevOps practices using Flyway's powerful migration framework, applicable to SQL Server, PostgreSQL, MySQL, and other major database platforms. We conclude with advanced topics including rollback strategies, environment-specific deployments, and integrating database changes with your application delivery pipeline.

## Workshop Prerequisites

Before starting this workshop, ensure you have:

- **Database Access**: SQL Server, PostgreSQL, or MySQL instance
- **Development Tools**:
  - Git for version control
  - IDE/Editor (VS Code recommended)
  - Java 8+ or Docker (for Flyway)
- **CI/CD Platform**: GitHub Actions, Azure DevOps, or Jenkins access
- **Basic Knowledge**: SQL fundamentals and basic command line usage

## Environment Setup

### Flyway Installation

#### Option 1: Command Line Tool

```bash
# Download Flyway Community Edition
wget -qO- https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/9.22.3/flyway-commandline-9.22.3-linux-x64.tar.gz | tar xvz
export PATH=$PATH:$PWD/flyway-9.22.3
```

#### Option 2: Docker

```bash
# Pull the official Flyway Docker image
docker pull flyway/flyway:latest
```

#### Option 3: Maven/Gradle Plugin

```xml
<!-- Add to your pom.xml -->
<plugin>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-maven-plugin</artifactId>
    <version>9.22.3</version>
</plugin>
```

## Workshop Labs

### [Lab 1: Getting Started with Flyway](training/flyway-autopilot/labs/lab1-getting-started/)

- 1.1: Install and configure Flyway for your environment
- 1.2: Create your first migration scripts
- 1.3: Execute migrations and understand versioning
- 1.4: Explore Flyway's command-line interface

### [Lab 2: Pipelines & Automation](training/flyway-autopilot/labs/lab2-pipelines-automation/)

- 2.1: Set up automated migration pipelines
- 2.2: Integrate Flyway with GitHub Actions
- 2.3: Configure environment-specific deployments
- 2.4: Implement migration validation and testing

### [Lab 3: Advanced Deployments](training/flyway-autopilot/labs/lab3-deployments/)

- 3.1: Handle complex schema changes
- 3.2: Manage data migrations safely
- 3.3: Implement blue-green database deployments
- 3.4: Configure environment promotion strategies

### [Lab 4: Version Control & Rollbacks](training/flyway-autopilot/labs/lab4-version-control/)

- 4.1: Advanced versioning strategies
- 4.2: Implement safe rollback procedures
- 4.3: Handle migration conflicts and repairs
- 4.4: Baseline existing databases

### [Lab 5: Monitoring & Troubleshooting](training/flyway-autopilot/labs/lab5-monitoring/)

- 5.1: Set up migration monitoring and alerting
- 5.2: Debug failed migrations
- 5.3: Performance optimization for large datasets
- 5.4: Audit trail and compliance reporting

### [Lab 6: Production Strategies](training/flyway-autopilot/labs/lab6-production/)

- 6.1: Zero-downtime deployment patterns
- 6.2: Multi-environment coordination
- 6.3: Security and access management
- 6.4: Disaster recovery and backup strategies

## About the Authors

This workshop is brought to you by [LetsMakeStuffGo](https://www.makestuffgo.com), a company dedicated to bringing AI services to both Cloud and DevOps Engineering practices. Our mission is to help organizations implement world-class DevOps practices that deliver real business value.

**Want to see how your company measures up?** Take our [FREE DevOps & FinOps Assessment](https://assessment.makestuffgo.com) to benchmark against industry standards.

## Overview

This workshop will guide you through implementing automated database deployment pipelines using modern DevOps practices.

## Training Modules

- [Flyway Autopilot Training](training/flyway-autopilot/)

## Quick Links

- [Workshop Overview](docs/workshop-overview)
- [Prerequisites](docs/prerequisites)
- [References](docs/references)
