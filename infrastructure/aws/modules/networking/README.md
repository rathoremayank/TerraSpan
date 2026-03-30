# AWS Networking Module

This Terraform module creates and manages VPC networking infrastructure including VPC, subnets, internet gateway, and route tables.

## Overview

The networking module provides:
- **VPC**: Virtual Private Cloud with customizable CIDR block
- **Public Subnets**: Multiple public subnets across availability zones
- **Private Subnets**: Multiple private subnets across availability zones  
- **Internet Gateway**: For routing traffic from public subnets to the internet
- **Route Tables**: Separate route tables for public and private subnets
- **Security Groups**: Base security group for ALB (can be extended for other resources)

## Architecture

```
VPC (10.0.0.0/16)
├── Internet Gateway
├── Public Subnets (10.0.0.0/19, 10.0.32.0/19)
│   ├── Route Table (0.0.0.0/0 → IGW)
│   └── EC2 Instances (optional)
└── Private Subnets (10.0.64.0/19, 10.0.96.0/19)
    └── Route Table (no internet route)
```

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  project_name       = "terraspan"
  environment        = "dev"
  region            = "us-east-1"
  vpc_cidr          = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  tags = {
    Project     = "terraspan"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_name` | Project name used for naming resources | string | - | yes |
| `environment` | Environment name (dev, staging, prod) | string | - | yes |
| `region` | AWS region | string | - | yes |
| `vpc_cidr` | CIDR block for VPC | string | `10.0.0.0/16` | no |
| `availability_zones` | List of availability zones | list(string) | - | yes |
| `tags` | Common tags for all resources | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `vpc_cidr` | VPC CIDR block |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `internet_gateway_id` | Internet Gateway ID |
| `public_route_table_id` | Public Route Table ID |
| `private_route_table_id` | Private Route Table ID |
| `alb_security_group_id` | ALB Security Group ID |

## Subnet Configuration

### CIDR Allocation
The module automatically calculates subnet CIDRs based on the VPC CIDR and number of availability zones:

- **VPC CIDR**: 10.0.0.0/16 (default)
- **Public Subnets**: Using /19 CIDR blocks (8,192 usable IPs each)
  - AZ1: 10.0.0.0/19
  - AZ2: 10.0.32.0/19
- **Private Subnets**: Using /19 CIDR blocks (8,192 usable IPs each)
  - AZ1: 10.0.64.0/19
  - AZ2: 10.0.96.0/19

### Routing Configuration

**Public Route Table**:
- Destination: 0.0.0.0/0 (all internet traffic)
- Target: Internet Gateway
- Associated with: All public subnets

**Private Route Table**:
- No internet route (instances have no direct internet access)
- Associated with: All private subnets

## Security Groups

### ALB Security Group
- **Inbound**:
  - HTTP (80/tcp) from 0.0.0.0/0
  - HTTPS (443/tcp) from 0.0.0.0/0
- **Outbound**: All traffic allowed

## Resource Naming Convention

Resources are named using the pattern: `{project_name}-{resource_type}-{environment}`

Examples:
- VPC: `terraspan-vpc-dev`
- Public Subnet: `terraspan-public-subnet-1`
- Private Subnet: `terraspan-private-subnet-1`
- IGW: `terraspan-igw-dev`
- Route Table: `terraspan-public-rt-dev`

## Free Tier Considerations

- **VPC**: No charges for VPC creation
- **Public IPs**: No charge for Elastic IPs if associated with running instances
- **Data Transfer**: No charges for data transfer within the VPC or to the internet (up to 1 GB/month free)
- **NAT Gateway** (not included): Would incur charges, use VPC endpoints instead

## Important Notes

1. **DNS Support**: DNS hostnames and DNS support are enabled by default
2. **Public IP Assignment**: Instances launched in public subnets automatically get public IPs
3. **Subnets per AZ**: The module creates one subnet per availability zone in each category (public/private)
4. **Scalability**: Easily add more availability zones by updating the `availability_zones` variable

## Terraform Commands

```bash
# Initialize the module
terraform init

# Plan the networking
terraform plan

# Apply the configuration
terraform apply

# Destroy the networking
terraform destroy
```

## Related Modules

- **Compute Module**: Deploy EC2 instances in the public or private subnets created by this module
- **Storage Module**: Create S3 buckets and other storage resources
- **Monitoring Module**: Set up CloudWatch and monitoring for networking resources
