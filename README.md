# TerraSpan - Multi-Cloud Infrastructure as Code

![TerraSpan](https://img.shields.io/badge/Terraform-IaC-blue)
![Multi-Cloud](https://img.shields.io/badge/Multi--Cloud-AWS%20%7C%20Azure%20%7C%20GCP-orange)
![License](https://img.shields.io/badge/License-Apache%202.0-green)

## Overview

**TerraSpan** is a production-grade, enterprise-ready Terraform project that enables seamless infrastructure provisioning and management across multiple cloud providers (AWS, Azure, and Google Cloud Platform). Built with a modular, scalable architecture, TerraSpan follows Terraform best practices and provides a foundation for managing complex, multi-cloud infrastructure deployments.

### Key Features

- 🌐 **Multi-Cloud Support**: Unified infrastructure management across AWS, Azure, and GCP
- 🏗️ **Modular Architecture**: Reusable, composable modules for networking, compute, storage, IAM, and monitoring
- 🔄 **Environment Management**: Built-in support for dev, staging, and production environments
- 🔒 **Production-Grade Security**: State encryption, RBAC, secrets management integration
- 📊 **Enterprise Monitoring**: Unified logging and monitoring across all cloud providers
- 🚀 **CI/CD Integration**: GitHub Actions workflows for automated validation and deployment
- 📚 **Comprehensive Documentation**: Detailed architecture docs, runbooks, and guides
- 💻 **Showcase Website**: Hugo-based static website demonstrating TerraSpan capabilities

## Project Structure

```
terraspan/
├── 0-requirements/              # Project requirements and specifications
│   └── requirements.md          # Detailed functional and non-functional requirements
├── infrastructure/              # Core infrastructure code
│   ├── core/                    # Shared global configurations
│   ├── aws/                     # AWS-specific infrastructure
│   │   ├── modules/             # Reusable AWS modules
│   │   └── environments/        # Environment-specific configurations
│   ├── azure/                   # Azure-specific infrastructure
│   │   ├── modules/             # Reusable Azure modules
│   │   └── environments/        # Environment-specific configurations
│   ├── gcp/                     # GCP-specific infrastructure
│   │   ├── modules/             # Reusable GCP modules
│   │   └── environments/        # Environment-specific configurations
│   └── remote-state/            # State backend configurations
├── website/                     # Product showcase website (Hugo)
├── .github/workflows/           # CI/CD automation
├── docs/                        # Extended documentation
└── README.md                    # This file
```

## Quick Start

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured (for AWS deployments)
- Azure CLI configured (for Azure deployments)
- Google Cloud SDK configured (for GCP deployments)
- Git for version control

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/terraspan.git
   cd terraspan
   ```

2. **Initialize Terraform**
   ```bash
   cd infrastructure/aws/environments/dev
   terraform init
   ```

3. **Validate configuration**
   ```bash
   terraform validate
   terraform plan
   ```

4. **Deploy infrastructure**
   ```bash
   terraform apply
   ```

For detailed setup instructions, see [Getting Started Guide](docs/getting-started.md).

## Cloud Providers

### AWS
- **Compute**: EC2, ECS, EKS
- **Networking**: VPC, Load Balancers, NAT
- **Storage**: S3, EBS, RDS
- **IAM**: Roles, Policies, Service Accounts
- **Monitoring**: CloudWatch, CloudTrail, X-Ray

### Azure
- **Compute**: Virtual Machines, AKS, App Service
- **Networking**: Virtual Networks, NSGs, Load Balancers
- **Storage**: Storage Accounts, Managed Disks, Cosmos DB
- **Identity**: Azure AD, Managed Identities, RBAC
- **Monitoring**: Azure Monitor, Application Insights, Log Analytics

### Google Cloud Platform
- **Compute**: Compute Engine, GKE, Cloud Run
- **Networking**: VPCs, Firewalls, Cloud Load Balancing
- **Storage**: Cloud Storage, Persistent Disks, Firestore
- **IAM**: Service Accounts, Custom Roles, Policies
- **Monitoring**: Cloud Monitoring, Cloud Logging, Trace

## Modules

### Available Modules

Each cloud provider includes the following reusable modules:

| Module | Purpose | Reusability |
|--------|---------|-------------|
| `networking` | VPC/VNet creation, subnetting, routing | High |
| `compute` | VM/instance provisioning, scaling | High |
| `storage` | Object storage, databases, persistence | High |
| `iam` | Identity, access control, roles | High |
| `monitoring` | Logging, metrics, dashboards, alerts | High |

### Module Usage Pattern

```hcl
module "aws_networking" {
  source = "../modules/networking"
  
  project_name = var.project_name
  environment  = var.environment
  region       = var.aws_region
  
  # Provider-specific variables
  vpc_cidr = var.vpc_cidr
  tags     = local.common_tags
}
```

## Environment Management

### Environments

```
environments/
├── dev/           # Development - experimental, cost-optimized
├── staging/       # Staging - pre-production, near-prod config
└── prod/          # Production - HA, DR, compliant
```

### Environment Configuration

Each environment has dedicated:
- `terraform.tfvars` - Environment-specific variables
- `backend.tf` - Dedicated state file
- `main.tf` - Environment entry point
- `variables.tf` - Environment variables definition

### Deploying to Different Environments

```bash
# Development deployment
cd infrastructure/aws/environments/dev
terraform init
terraform plan
terraform apply

# Production deployment (requires approval)
cd infrastructure/aws/environments/prod
terraform init
terraform plan
terraform apply
```

## State Management

### Remote State Configuration

TerraSpan uses remote state management for production reliability:

**AWS**: S3 backend with DynamoDB locking
**Azure**: Azure Storage Account backend
**GCP**: Google Cloud Storage backend

### State Backend Setup

See [Remote State Documentation](infrastructure/remote-state/README.md) for:
- Backend initialization procedures
- State locking configuration
- Backup and recovery procedures
- State file access controls

## CI/CD Pipeline

### GitHub Actions Workflows

TerraSpan includes automated CI/CD workflows:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `validate` | Pull Request | Code validation, linting, formatting |
| `plan` | Pull Request | terraform plan with detailed output |
| `apply` | Merge to main | Deployment with manual approval |
| `destroy` | Manual trigger | Controlled infrastructure destruction |

### Running Workflows

Workflows are automatically triggered on:
- Pull requests (validation only)
- Commits to main branch (apply with approval)
- Manual dispatch triggers

See [CI/CD Documentation](.github/workflows/README.md) for detailed workflow information.

## Website

The TerraSpan website is a static site built with Hugo that showcases:
- Project features and capabilities
- Multi-cloud architecture
- Getting started guides
- Documentation and tutorials
- Case studies and testimonials

### Building the Website

```bash
cd website
hugo server -D  # Development server
hugo            # Production build
```

Website source: [website/README.md](website/README.md)

## Documentation

### Key Documentation Files

- [Getting Started Guide](docs/getting-started.md) - Initial setup and first deployment
- [Architecture Guide](docs/architecture.md) - System design and principles
- [Module Documentation](docs/modules/README.md) - Detailed module reference
- [Deployment Guide](docs/deployment.md) - Production deployment procedures
- [Troubleshooting Guide](docs/troubleshooting.md) - Common issues and solutions
- [Contributing Guide](CONTRIBUTING.md) - Development guidelines
- [Change Log](CHANGELOG.md) - Version history and updates

## Best Practices Implemented

✅ **Modularity**: Reusable, independently deployable modules
✅ **DRY Principle**: Eliminate code duplication through variables and modules
✅ **Environment Strategy**: Clear separation between dev/staging/prod
✅ **State Management**: Secure remote state with locking and encryption
✅ **Security**: Secrets management, RBAC, encryption, audit logs
✅ **Testing**: Validation, planning, and integration tests
✅ **Documentation**: Comprehensive guides and inline code documentation
✅ **Version Control**: Clear git history with conventional commits
✅ **Cost Optimization**: Right-sizing, tagging, and monitoring

## Security

### Security Features

- 🔐 **State Encryption**: Terraform state encrypted at rest
- 🔏 **Secrets Management**: Integration with cloud-native secret managers
- 👤 **IAM Best Practices**: Principle of least privilege, role-based access
- 🔍 **Audit Logging**: All infrastructure changes logged and traceable
- 🛡️ **Network Security**: Security groups, NACLs, firewalls configured correctly
- 📊 **Compliance**: SOC 2, HIPAA-ready infrastructure templates

### Security Scanning

- SAST: terraform validate, tflint
- Dependency scanning: Regular vulnerability updates
- Pre-commit hooks: Prevent accidentally committing secrets

## Cost Optimization

TerraSpan includes built-in cost optimization:

- Right-sized instance types per environment
- development environment cost controls  
- Reserved instance support
- Spot instance options (where applicable)
- Resource tagging for cost allocation
- Cost monitoring dashboards

See [Cost Optimization Guide](docs/cost-optimization.md) for recommendations.

## Troubleshooting

### Common Issues

**State Lock Timeout**
```bash
# Force unlock (use with caution!)
terraform force-unlock <LOCK_ID>
```

**Module Version Conflicts**
```bash
# Upgrade all modules
terraform get -update
terraform init -upgrade
```

**Authentication Errors**
```bash
# Re-authenticate with cloud provider
aws configure  # AWS
az login       # Azure
gcloud auth login  # GCP
```

See [Troubleshooting Guide](docs/troubleshooting.md) for more solutions.

## Contributing

We welcome contributions! Please see [Contributing Guide](CONTRIBUTING.md) for:
- Code style guidelines
- Testing requirements
- Pull request process
- Issue reporting templates

## License

This project is licensed under the Apache License 2.0 - see [LICENSE](LICENSE) file for details.

## Support

- 📖 [Documentation](docs/)
- 🐛 [Issue Tracker](https://github.com/your-org/terraspan/issues)
- 💬 [Discussions](https://github.com/your-org/terraspan/discussions)
- 📧 Email: support@terraspan.dev

## Roadmap

### Upcoming Features

- [ ] Kubernetes cluster management across all three providers
- [ ] Enhanced monitoring and observability stack
- [ ] Automated compliance checking and reporting
- [ ] Multi-tenancy support framework
- [ ] Advanced disaster recovery automation
- [ ] Cost forecasting and optimization engine
- [ ] GitOps integration (ArgoCD, Flux)

See [Roadmap](docs/roadmap.md) for detailed feature planning.

## Acknowledgments

- Built with [Terraform](https://www.terraform.io/)
- CI/CD powered by [GitHub Actions](https://github.com/features/actions)
- Website built with [Hugo](https://gohugo.io/)

---

**Made with ❤️ for the infrastructure community**
