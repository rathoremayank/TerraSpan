# Getting Started with TerraSpan

Welcome to TerraSpan! This guide will help you set up and deploy your first multi-cloud infrastructure in minutes.

## Prerequisites

Before you begin, ensure you have:

- **Terraform** >= 1.5.0 installed
- **Git** for version control
- **Cloud CLI tools**:
  - AWS CLI (for AWS deployments)
  - Azure CLI (for Azure deployments)
  - Google Cloud SDK (for GCP deployments)
- **Text editor** or IDE (VS Code recommended)

### Installation

#### macOS

```bash
# Using Homebrew
brew install terraform git awscli azure-cli google-cloud-sdk
```

#### Windows

```bash
# Using Chocolatey
choco install terraform git awscli azure-cli googcloud-cli
```

#### Linux

```bash
# Using apt (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install terraform git awscli azure-cli google-cloud-sdk
```

## Quick Start (5 Minutes)

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/terraspan.git
cd terraspan
```

### 2. Configure Cloud Provider Credentials

Choose your cloud provider:

#### AWS

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter default region (e.g., us-east-1)
# Enter default output format (json)
```

#### Azure

```bash
az login
# Browser will open for authentication
az account set --subscription <SUBSCRIPTION_ID>
```

#### GCP

```bash
gcloud auth login
gcloud config set project <PROJECT_ID>
```

### 3. Initialize Terraform

Navigate to your desired environment:

```bash
# For development environment on AWS
cd infrastructure/aws/environments/dev

# Initialize Terraform
terraform init
```

### 4. Review the Plan

```bash
# Create infrastructure plan
terraform plan
```

This will show all resources that Terraform will create.

### 5. Deploy Infrastructure

```bash
# Apply the configuration
terraform apply

# Review the changes and type 'yes' to confirm
```

Congratulations! Your first multi-cloud infrastructure is deployed. 🎉

## Project Structure Overview

Understanding the directory structure will help you navigate:

```
terraspan/
├── infrastructure/           # All infrastructure code
│   ├── aws/                 # AWS-specific code
│   ├── azure/               # Azure-specific code
│   ├── gcp/                 # GCP-specific code
│   │   ├── modules/         # Reusable modules
│   │   └── environments/    # Environment configs
│   └── core/                # Shared configurations
├── website/                 # Project website
├── .github/workflows/       # CI/CD automation
└── docs/                    # Documentation
```

## Key Concepts

### Modules

Modules are reusable components for common infrastructure patterns:
- **Networking**: VPCs, subnets, security groups
- **Compute**: VMs, containers, serverless
- **Storage**: Object storage, databases
- **IAM**: Identity and access management
- **Monitoring**: Logging and alerting

### Environments

Three standard environments:
- **Dev**: Development and testing
- **Staging**: Pre-production validation
- **Prod**: Production workloads

Each has separate state and configuration.

### Cloud Providers

TerraSpan supports:
- **AWS**: Amazon Web Services
- **Azure**: Microsoft Azure
- **GCP**: Google Cloud Platform

Deploy to any or all simultaneously.

## First Deployment Checklist

- [ ] Prerequisites installed
- [ ] Repository cloned
- [ ] Cloud credentials configured
- [ ] Terraform initialized
- [ ] Plan reviewed
- [ ] Infrastructure deployed
- [ ] Resources verified in cloud console
- [ ] Outputs recorded

## Next Steps

### 1. Explore the Deployed Infrastructure

```bash
# Show all resources
terraform state list

# Show specific resource details
terraform state show aws_vpc.main
```

### 2. Modify Your Infrastructure

Edit `terraform.tfvars` to customize:

```hcl
vpc_cidr          = "10.1.0.0/16"  # Change VPC CIDR
availability_zones = ["us-east-1a"] # Change AZs
```

Then apply changes:

```bash
terraform plan   # Review changes
terraform apply  # Apply changes
```

### 3. Deploy to Multiple Environments

```bash
# Deploy to staging
cd ../staging
terraform init
terraform apply

# Deploy to production
cd ../prod
terraform init
terraform apply
```

### 4. Add More Modules

Extend your infrastructure by adding modules:

```hcl
module "compute" {
  source = "../modules/compute"
  
  # Add your configuration here
}
```

### 5. Set Up CI/CD

Commit your changes to trigger automated deployment:

```bash
git add .
git commit -m "feat: initial infrastructure"
git push origin main
```

GitHub Actions workflows will validate and deploy automatically.

## Common Commands

### Planning & Deployment

```bash
# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Create plan
terraform plan -out=tfplan

# Apply plan
terraform apply tfplan

# Destroy infrastructure
terraform destroy
```

### State Management

```bash
# List all resources
terraform state list

# Show resource details
terraform state show <resource>

# Pull current state
terraform state pull

# Push new state
terraform state push state.json
```

### Debugging

```bash
# Enable debug mode
export TF_LOG=DEBUG

# Validate Terraform
terraform validate

# Show current state
terraform show

# Show plan details
terraform show tfplan
```

## Troubleshooting

### Error: Provider not authorized

```bash
# Re-authenticate with your cloud provider

# AWS
aws configure

# Azure
az login

# GCP
gcloud auth login
```

### Error: "Resource already exists"

```bash
# Import existing resource
terraform import <resource> <id>

# Example for AWS
terraform import aws_vpc.main vpc-12345678
```

### Error: "Backend initialization failed"

```bash
# Re-initialize backend
terraform init -reconfigure

# Force new backend
terraform init -migrate-state
```

## Get Help

- **Documentation**: See [docs/](../docs/) directory
- **FAQ**: Check [docs/faq.md](../docs/faq.md)
- **Issues**: Browse [GitHub Issues](https://github.com/your-org/terraspan/issues)
- **Discussions**: Join [GitHub Discussions](https://github.com/your-org/terraspan/discussions)
- **Support**: Email support@terraspan.dev

## Next Learning Resources

1. [Architecture Guide](../docs/architecture.md) - Understand the design
2. [Deployment Guide](../docs/deployment.md) - Production deployment
3. [Module Development](../docs/modules/README.md) - Create custom modules
4. [Security Guide](../docs/security.md) - Secure your infrastructure
5. [Contributing](../CONTRIBUTING.md) - Help improve TerraSpan

---

**Congrats on getting started!** 🚀

For advanced topics, proceed to the [main documentation](../docs/README.md).
