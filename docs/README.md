# Documentation

This directory contains comprehensive documentation for the TerraSpan project.

## Quick Links

### Getting Started
- [Quick Start Guide](getting-started.md) - First deployment in 5 minutes
- [Architecture Overview](architecture.md) - System design principles

### Deployment & Operations
- [Deployment Guide](deployment.md) - Step-by-step deployment instructions
- [State Management](../infrastructure/remote-state/README.md) - Remote state configuration
- [CI/CD Pipeline](.github/workflows/README.md) - Automated deployment workflows

### Module Reference
- [AWS Modules](../infrastructure/aws/README.md) - AWS-specific modules
- [Azure Modules](../infrastructure/azure/README.md) - Azure-specific modules
- [GCP Modules](../infrastructure/gcp/README.md) - GCP-specific modules
- [Core Module](../infrastructure/core/README.md) - Shared configurations

### Advanced Topics
- [Troubleshooting Guide](troubleshooting.md) - Common issues and solutions
- [Cost Optimization](cost-optimization.md) - Reducing cloud costs
- [Security Best Practices](security.md) - Securing your infrastructure
- [Contributing Guide](../CONTRIBUTING.md) - How to contribute

## Directory Structure

```
docs/
├── README.md                    # This file
├── getting-started.md          # Quick start guide
├── architecture.md             # System architecture
├── deployment.md               # Deployment procedures
├── security.md                 # Security guidelines
├── cost-optimization.md        # Cost reduction strategies
├── troubleshooting.md          # Issue resolution
├── modules/
│   ├── README.md              # Module development guide
│   ├── networking.md          # Networking module guide
│   ├── compute.md             # Compute module guide
│   ├── storage.md             # Storage module guide
│   ├── iam.md                 # IAM module guide
│   └── monitoring.md          # Monitoring module guide
├── examples/
│   ├── aws/                   # AWS examples
│   ├── azure/                 # Azure examples
│   └── gcp/                   # GCP examples
├── screenshots/               # Documentation images
├── diagrams/                  # Architecture diagrams
└── faq.md                     # Frequently asked questions
```

## Finding Information

### By Role

**CloudOps/Infrastructure Engineers**
- Start: [Quick Start Guide](getting-started.md)
- Next: [Deployment Guide](deployment.md)
- Reference: Cloud provider READMEs

**Developers**
- Start: [Contributing Guide](../CONTRIBUTING.md)
- Reference: [Module Development](modules/README.md)

**Security/Compliance**
- Primary: [Security Best Practices](security.md)
- Reference: Remote state, RBAC documentation

**Finance/Management**
- Primary: [Cost Optimization](cost-optimization.md)
- Reference: Architecture guide

### By Task

**Initial Setup**
1. [Getting Started](getting-started.md)
2. [Architecture](architecture.md)
3. Cloud provider setup

**Production Deployment**
1. [Deployment Guide](deployment.md)
2. [Remote State](../infrastructure/remote-state/README.md)
3. [Security](security.md)

**Troubleshooting**
1. [Troubleshooting Guide](troubleshooting.md)
2. Cloud provider READMEs
3. [FAQ](faq.md)

## Key Concepts

### Modularity
TerraSpan uses highly reusable modules that can be composed to create complex infrastructure. Each module:
- Has clear inputs and outputs
- Is independently deployable
- Follows naming conventions
- Includes comprehensive documentation

### Multi-Cloud Strategy
Deploy identical infrastructure across AWS, Azure, and GCP with cloud-specific customizations where needed. Common patterns across providers mean:
- Easier operations
- Multi-cloud resilience
- Reduced vendor lock-in

### Environment Management
Three standard environments:
- **Dev**: Experimental, cost-optimized
- **Staging**: Pre-production testing
- **Prod**: Production workloads, HA/DR

### Infrastructure as Code Best Practices
- Version-controlled infrastructure
- Reproducible deployments
- Change tracking and audit trail
- Automated testing and validation

## Common Workflows

### Planning Changes
```bash
cd infrastructure/{provider}/environments/{env}
terraform plan -out=tfplan
terraform show tfplan
```

### Applying Changes
```bash
terraform apply tfplan
```

### Viewing Current State
```bash
terraform state list
terraform state show {resource}
```

### Rolling Back Changes
```bash
# Review existing state
terraform show

# Revert to previous state version
terraform state pull > current.state
# Restore from backup
terraform state push backup.state
```

## Getting Help

### Documentation Doesn't Help?

1. **Check [FAQ](faq.md)** - Common questions answered
2. **Read [Troubleshooting](troubleshooting.md)** - Issue-specific solutions
3. **Search Issues** - GitHub issues may contain solutions
4. **Ask in Discussions** - Community help available
5. **Contact Support** - support@terraspan.dev

### Report a Problem

1. Check existing issues first
2. Gather diagnostic information:
   - Terraform version
   - Cloud provider and region
   - TerraSpan version
   - Error messages and logs
3. Create new issue with details

## Contributing to Documentation

Documentation improvements are welcome! To contribute:

1. Fork the repository
2. Create feature branch: `docs/improvement`
3. Make changes in Markdown
4. Test rendering: `hugo server -D`
5. Submit pull request

See [Contributing Guide](../CONTRIBUTING.md) for full details.

## Document Conventions

### Markdown Format

- Use ATX-style headers (# ## ###)
- Code blocks with language identifier
- Bullet lists for unordered items
- Numbered lists for procedures
- Links relative to project root

### Code Examples

```hcl
# Include language identifier
# Add context or comments
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

### Command Examples

```bash
# Commands should be ready to copy/paste
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Document Status

- ✅ Getting Started - Complete
- ✅ Architecture - Complete
- ✅ Deployment - In Progress
- 🔄 Troubleshooting - Needs Expansion
- 📋 Advanced Topics - Planned

Last Updated: March 29, 2026
