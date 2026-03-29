# TerraSpan Architecture

This document describes the architecture and design principles of TerraSpan.

## Overview

TerraSpan is a production-grade Infrastructure-as-Code (IaC) project that provides a unified approach to managing infrastructure across multiple cloud providers (AWS, Azure, Google Cloud Platform).

## Design Principles

### 1. **Multi-Cloud Agnostic**
- Common infrastructure patterns across providers
- Cloud-specific modules where needed
- Easy migration between services

### 2. **Modular and Reusable**
- Independent, composable modules
- DRY (Don't Repeat Yourself) principle
- Clear separation of concerns

### 3. **Environment Isolation**
- Separate state per environment
- Environment-specific configurations
- Promotion workflow (dev → staging → prod)

### 4. **Security First**
- Encryption by default
- Least privilege access
- Audit logging enabled
- Secrets management integrated

### 5. **Operational Excellence**
- Automation wherever possible
- Clear runbooks and procedures
- Comprehensive monitoring
- Rapid troubleshooting capabilities

## Directory Architecture

```
terraspan/
│
├── infrastructure/              # All infrastructure code
│   ├── core/                   # Shared configurations
│   │   ├── main.tf            # Global resources
│   │   ├── variables.tf       # Common variables
│   │   └── locals.tf          # Computed values
│   │
│   ├── aws/                    # AWS provider
│   │   ├── modules/
│   │   │   ├── networking/    # VPC, subnets, security groups
│   │   │   ├── compute/       # EC2, ECS, EKS
│   │   │   ├── storage/       # S3, RDS, EBS
│   │   │   ├── iam/           # Roles, policies
│   │   │   └── monitoring/    # CloudWatch, logs
│   │   │
│   │   └── environments/
│   │       ├── dev/           # Development config
│   │       ├── staging/       # Staging config
│   │       └── prod/          # Production config
│   │
│   ├── azure/                  # Azure provider
│   │   ├── modules/
│   │   │   ├── networking/    # VNets, NSGs
│   │   │   ├── compute/       # VMs, AKS
│   │   │   ├── storage/       # Storage accounts, databases
│   │   │   ├── iam/           # Azure AD, RBAC
│   │   │   └── monitoring/    # Azure Monitor, logs
│   │   │
│   │   └── environments/
│   │       ├── dev/
│   │       ├── staging/
│   │       └── prod/
│   │
│   ├── gcp/                    # GCP provider
│   │   ├── modules/
│   │   │   ├── networking/    # VPCs, firewalls
│   │   │   ├── compute/       # GCE, GKE
│   │   │   ├── storage/       # GCS, databases
│   │   │   ├── iam/           # Service accounts, roles
│   │   │   └── monitoring/    # Cloud Monitoring, logs
│   │   │
│   │   └── environments/
│   │       ├── dev/
│   │       ├── staging/
│   │       └── prod/
│   │
│   └── remote-state/          # State backend configs
│       ├── aws/               # S3 + DynamoDB setup
│       ├── azure/             # Storage account setup
│       └── gcp/               # GCS setup
│
├── website/                    # Static website (Hugo)
│   ├── config.toml
│   ├── content/               # Markdown pages
│   ├── static/                # CSS, JS, images
│   └── themes/
│
├── .github/                    # GitHub configuration
│   └── workflows/             # CI/CD automation
│       ├── validate.yml       # Code validation
│       ├── plan.yml          # Infrastructure plan
│       └── apply.yml         # Infrastructure apply
│
└── docs/                       # Documentation
    ├── architecture.md
    ├── deployment.md
    ├── security.md
    └── troubleshooting.md
```

## Module Architecture

### Module Layers

```
┌─────────────────────────────────────────┐
│      Environments (dev/staging/prod)    │ ← Entry point
├─────────────────────────────────────────┤
│  Provider-specific module compositions  │ ← Orchestration
├─────────────────────────────────────────┤
│     Cloud provider modules              │ ← Implementation
│  networking | compute | storage | IAM   │
├─────────────────────────────────────────┤
│         Core/Global resources           │ ← Shared values
└─────────────────────────────────────────┘
```

### Module Dependencies

```
environment/
  main.tf
    ↓
  module "networking"  ──┐
    ↓                    ├→ Outputs
  module "compute" ──────┤  (vpc_id, subnet_ids)
    ↓                    │
  module "iam" ─────────┘
```

## State Management Architecture

### State File Organization

```
Remote Backend (S3/Azure/GCS)
├── aws/
│   ├── dev/terraform.tfstate
│   ├── staging/terraform.tfstate
│   └── prod/terraform.tfstate
├── azure/
│   ├── dev/terraform.tfstate
│   ├── staging/terraform.tfstate
│   └── prod/terraform.tfstate
└── gcp/
    ├── dev/terraform.tfstate
    ├── staging/terraform.tfstate
    └── prod/terraform.tfstate
```

### State Locking

```
┌──────────────────┐
│ Apply Operation  │
└────────┬─────────┘
         │
    ┌────▼─────┐
    │Lock State │
    └────┬─────┘
         │
  ┌──────▼──────┐
  │   Update    │ ← Protected from concurrent modifications
  │Infrastructure│
  └──────┬──────┘
         │
  ┌──────▼──────┐
  │Unlock State │
  └─────────────┘
```

## CI/CD Pipeline Architecture

### Workflow Stages

```
┌─────────────────────────────────────────┐
│   Developer Creates Pull Request        │
└────────┬────────────────────────────────┘
         │
    ┌────▼──────────────────┐
    │ Validation Stage      │ ← terraform validate, fmt, lint
    │ ✓ Format Check        │
    │ ✓ Syntax Validation   │
    │ ✓ Security Scan       │
    └────┬───────────────────┘
         │
    ┌────▼──────────────────┐
    │ Planning Stage        │ ← terraform plan
    │ ✓ AWS Plan            │
    │ ✓ Azure Plan          │
    │ ✓ GCP Plan            │
    │ ✓ PR Comment          │
    └────┬───────────────────┘
         │
    ┌────▼──────────────────┐
    │ Review & Approval     │ ← Manual gate
    └────┬───────────────────┘
         │
    ┌────▼──────────────────┐
    │ Merge to Main         │
    └────┬───────────────────┘
         │
    ┌────▼──────────────────┐
    │ Apply Stage           │ ← terraform apply
    │ ✓ AWS Apply           │
    │ ✓ Azure Apply         │
    │ ✓ GCP Apply           │
    │ ✓ Notifications       │
    └─────────────────────────────────────────┘
```

## Environment Architecture

### Development Environment
```
Low cost | Single AZ | Minimal redundancy | Testing focus
        ↓
  ┌─────────────────┐
  │ EC2 t3.micro    │
  │ RDS Single-AZ   │
  │ S3 Standard     │
  └─────────────────┘
```

### Staging Environment
```
Match production features | Multi-AZ | Test scale
        ↓
  ┌─────────────────┐
  │ EC2 t3.small ×2 │
  │ RDS Multi-AZ    │
  │ S3 GRS          │
  └─────────────────┘
```

### Production Environment
```
High availability | Multi-AZ/Region | Full redundancy
        ↓
  ┌─────────────────┐
  │ EC2 m5.large ×3 │
  │ RDS Multi-AZ    │
  │ S3 Multi-Region │
  │ Auto Scaling    │
  └─────────────────┘
```

## Security Architecture

### Network Security

```
┌────────────────────────────────────────┐
│         Internet (0.0.0.0/0)           │
└─────────────┬──────────────────────────┘
              │
       ┌──────▼────────┐
       │ Load Balancer │
       │ (Public)      │
       └──────┬────────┘
              │
    ┌─────────▼───────────┐
    │ Security Group /NSG │ ← Ingress/Egress rules
    └─────────┬───────────┘
              │
      ┌───────▼──────────┐
      │ Application      │ ← Private subnet
      │ (Private)        │
      └───────┬──────────┘
              │
      ┌───────▼──────────┐
      │ Database         │ ← Private subnet
      │ (Encrypted)      │
      └──────────────────┘
```

### Identity and Access

```
┌──────────────────┐
│ Service Account  │
│ (Least Privilege)│
└────────┬─────────┘
         │
    ┌────▼────────┐
    │ Assume Role  │
    └────┬────────┘
         │
    ┌────▼──────────────┐
    │ Temporary Token   │ ← Time-limited
    └──────────────────┘
```

## Data Flow

### Infrastructure Deployment Flow

```
Developer
    ↓
Git Repository
    ↓
GitHub Actions
    ├→ Validate
    ├→ Plan
    ├→ Approval
    └→ Apply
        ├→ AWS API
        ├→ Azure API
        └→ GCP API
            ↓
        Infrastructure Created
            ↓
        Monitoring & Logging
```

## Scalability Considerations

### Horizontal Scaling

```
┌──────────────┐
│  TerraSpan   │
│  Framework   │
└──────────────┘
      ↓
┌────────────────────────────────┐
│   Add More Environments         │ ← Easy to replicate
│   Add More Clouds              │ ← Generic modules
│   Add More Modules             │ ← Composable design
└────────────────────────────────┘
```

### Vertical Scaling

```
Single Resource → Module → Collection → Platform
  (t3.micro)    (networking) (complete     (complete
                           environments) cloud layer)
```

## Best Practices Implemented

### 1. **DRY Principle**
- Shared modules reduce duplication
- Common variables centralized
- Reusable outputs

### 2. **Separation of Concerns**
- One module, one responsibility
- Clear interfaces (input/output)
- Cloud-specific and cloud-agnostic

### 3. **Version Control**
- All code in Git
- Clear commit history
- Change tracking

### 4. **Testing & Validation**
- Automated validation
- Planning before apply
- Security scanning

### 5. **Monitoring & Observability**
- Centralized logging
- Infrastructure metrics
- Audit trails

---

For detailed module architecture, see [Module Development](modules/README.md).
