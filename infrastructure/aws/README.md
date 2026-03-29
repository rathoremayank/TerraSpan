# AWS Infrastructure Module

This directory contains all AWS-specific infrastructure code for TerraSpan, organized into reusable modules and environment-specific configurations.

## Directory Structure

```
aws/
├── modules/                    # Reusable AWS modules
│   ├── networking/            # VPC, subnets, security groups, load balancers
│   ├── compute/               # EC2, ECS, EKS, Auto Scaling Groups
│   ├── storage/               # S3, EBS, RDS, database resources
│   ├── iam/                   # IAM roles, policies, service accounts
│   └── monitoring/            # CloudWatch, CloudTrail, X-Ray configurations
└── environments/              # Environment-specific deployments
    ├── dev/                   # Development environment
    ├── staging/               # Staging environment
    └── prod/                  # Production environment
```

## AWS Modules

### 1. Networking Module (`networking/`)

Creates and manages AWS networking infrastructure.

**Outputs**: VPC ID, subnet IDs, security group IDs, load balancer DNS

**Variables**:
- `vpc_cidr`: VPC CIDR block (e.g., "10.0.0.0/16")
- `environment`: Environment name (dev/staging/prod)
- `region`: AWS region
- `availability_zones`: List of AZs for deployment

**Example**:
```hcl
module "networking" {
  source = "../modules/networking"
  
  vpc_cidr             = "10.0.0.0/16"
  environment          = "dev"
  region              = "us-east-1"
  availability_zones  = ["us-east-1a", "us-east-1b"]
  
  tags = merge(
    local.common_tags,
    { Name = "terraspan-network-dev" }
  )
}
```

### 2. Compute Module (`compute/`)

Manages EC2 instances, ECS clusters, EKS clusters, and Auto Scaling Groups.

**Outputs**: Instance IDs, cluster names, load balancer endpoints

**Variables**:
- `instance_type`: EC2 instance type (e.g., "t3.medium")
- `desired_capacity`: Desired number of instances
- `key_pair_name`: EC2 key pair for SSH access
- `enable_monitoring`: Enable CloudWatch detailed monitoring

**Example**:
```hcl
module "compute" {
  source = "../modules/compute"
  
  instance_type       = "t3.medium"
  desired_capacity    = 2
  enable_monitoring   = true
  
  tags = local.common_tags
}
```

### 3. Storage Module (`storage/`)

Creates S3 buckets, EBS volumes, and RDS database instances.

**Outputs**: Bucket names, bucket ARNs, database endpoints

**Variables**:
- `bucket_prefix`: S3 bucket name prefix
- `db_engine`: Database engine (postgres, mysql, mariadb)
- `db_allocated_storage`: Database storage in GB
- `enable_encryption`: Enable S3 encryption

**Example**:
```hcl
module "storage" {
  source = "../modules/storage"
  
  bucket_prefix          = "terraspan-dev"
  db_engine             = "postgres"
  db_allocated_storage  = 20
  enable_encryption     = true
  
  tags = local.common_tags
}
```

### 4. IAM Module (`iam/`)

Defines IAM roles, policies, and service accounts for least-privilege access.

**Outputs**: Role ARNs, policy ARNs, service account identifiers

**Variables**:
- `service_names`: List of services requiring IAM roles
- `policy_attachments`: Managed policy ARNs to attach
- `inline_policies`: Custom inline policies

**Example**:
```hcl
module "iam" {
  source = "../modules/iam"
  
  service_names = ["ec2", "ecs", "lambda"]
  
  inline_policies = {
    s3_access = file("${path.module}/policies/s3-access.json")
  }
  
  tags = local.common_tags
}
```

### 5. Monitoring Module (`monitoring/`)

Sets up CloudWatch dashboards, alarms, logging, and CloudTrail.

**Outputs**: Dashboard URLs, log group names, alarm ARNs

**Variables**:
- `enable_cloudtrail`: Enable CloudTrail logging
- `log_retention_days`: CloudWatch logs retention in days
- `alarm_email`: Email for SNS notifications
- `log_group_prefix`: CloudWatch log group prefix

**Example**:
```hcl
module "monitoring" {
  source = "../modules/monitoring"
  
  enable_cloudtrail      = true
  log_retention_days     = 30
  alarm_email           = "ops@terraspan.dev"
  log_group_prefix      = "/aws/terraspan"
  
  tags = local.common_tags
}
```

## AWS Environments

### Development Environment (`environments/dev/`)

- **Purpose**: Experimental deployments, feature testing
- **Cost Optimization**: Minimal resources, single AZ
- **Backup**: Daily backups, 7-day retention
- **Configuration File**: `terraform.tfvars`

### Staging Environment (`environments/staging/`)

- **Purpose**: Pre-production validation
- **Configuration**: Near-production setup
- **Backup**: Daily backups, 14-day retention
- **Compliance**: Pre-compliance validation

### Production Environment (`environments/prod/`)

- **Purpose**: Live production workloads
- **Reliability**: Multi-AZ deployment, high availability
- **Backup**: Continuous backup, 30-day retention
- **Compliance**: Full compliance validation
- **Monitoring**: Enhanced monitoring and alerting
- **Approval**: Requires manual approval for apply

## Common Variables

All AWS modules use these common variables:

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `project_name` | string | Yes | Project identifier |
| `environment` | string | Yes | Environment (dev/staging/prod) |
| `region` | string | Yes | AWS region |
| `tags` | map(string) | No | Common tags for all resources |

## AWS Best Practices Implemented

✅ **VPC Design**: Public/private subnet separation, NAT for outbound traffic
✅ **Security Groups**: Principle of least privilege, ingress/egress rules
✅ **IAM**: Service-specific roles, managed policies, inline policies as needed
✅ **Networking**: Multi-AZ deployment, elastic load balancing
✅ **Storage**: Encryption at rest, versioning, lifecycle policies
✅ **Monitoring**: CloudWatch dashboards, alarms, centralized logging
✅ **Backup**: Regular backups with retention policies
✅ **Cost**: Right-sized instances, scheduled scaling, spot instances where applicable

## Deployment

### Initialize AWS Environment

```bash
cd environments/dev
terraform init -backend-config="key=terraspan/aws/dev.tfstate"
```

### Plan Deployment

```bash
terraform plan -out=tfplan
```

### Apply Configuration

```bash
terraform apply tfplan
```

### Destroy Infrastructure

```bash
# List all resources
terraform state list

# Destroy with confirmation
terraform destroy

# Force destroy (use with caution)
terraform destroy -auto-approve
```

## State Management

- **Backend**: S3 bucket with DynamoDB locking
- **Encryption**: State encrypted at rest using KMS
- **Versioning**: S3 versioning enabled for state recovery
- **Access**: IAM policies restrict state access

See [Remote State Configuration](../remote-state/README.md) for setup details.

## Troubleshooting

### Common Issues

**Authentication Error**
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Reconfigure AWS credentials
aws configure
```

**State Lock**
```bash
# List locks
terraform state list

# Force unlock (use with caution!)
terraform force-unlock <LOCK_ID>
```

**Resource Already Exists**
```bash
# Import existing resource
terraform import aws_instance.example i-0123456789abcdef
```

## Related Documentation

- [AWS Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/)
- [TerraSpan Main README](../../README.md)
- [Deployment Guide](../../docs/deployment.md)

## Support

For AWS-specific issues, check:
- AWS CloudTrail logs for API calls
- CloudWatch logs for application errors
- VPC Flow Logs for network diagnostics
- AWS Support: [AWS Support Center](https://console.aws.amazon.com/support/)
