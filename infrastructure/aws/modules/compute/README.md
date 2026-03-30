# AWS Compute Module

This Terraform module creates and manages EC2 compute resources including EC2 instances and security groups.

## Overview

The compute module provides:
- **EC2 Instances**: Two t2.micro instances (free tier eligible) in the public subnet
  - Jenkins Server: For CI/CD pipelines
  - Minikube Server: For local Kubernetes development
- **Security Groups**: Separate security groups for Jenkins and Minikube with appropriate ingress/egress rules
- **User Data Scripts**: Automated setup scripts for Jenkins and Minikube

## Architecture

```
VPC
├── Public Subnet
│   ├── Jenkins EC2 (t2.micro)
│   │   └── Security Group (SSH: 22, Jenkins: 8080)
│   └── Minikube EC2 (t2.micro)
│       └── Security Group (SSH: 22, Kubernetes: 6443, NodePort: 30000-32767)
```

## Usage

```hcl
module "compute" {
  source = "../../modules/compute"

  project_name     = "terraspan"
  environment      = "dev"
  vpc_id           = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnet_ids[0]
  instance_type    = "t2.micro"

  tags = {
    Project     = "terraspan"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

  depends_on = [module.networking]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_name` | Project name used for naming resources | string | - | yes |
| `environment` | Environment name (dev, staging, prod) | string | - | yes |
| `vpc_id` | VPC ID where resources will be created | string | - | yes |
| `public_subnet_id` | Public subnet ID for EC2 instances | string | - | yes |
| `instance_type` | EC2 instance type (t2.micro for free tier) | string | `t2.micro` | no |
| `tags` | Common tags for all resources | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `jenkins_instance_id` | Jenkins EC2 instance ID |
| `jenkins_public_ip` | Jenkins EC2 public IP address |
| `jenkins_security_group_id` | Jenkins security group ID |
| `minikube_instance_id` | Minikube EC2 instance ID |
| `minikube_public_ip` | Minikube EC2 public IP address |
| `minikube_security_group_id` | Minikube security group ID |

## Security Groups

### Jenkins Security Group
- **Inbound**:
  - SSH (22/tcp) from 0.0.0.0/0
  - Jenkins Web (8080/tcp) from 0.0.0.0/0
- **Outbound**: All traffic allowed

### Minikube Security Group
- **Inbound**:
  - SSH (22/tcp) from 0.0.0.0/0
  - Kubernetes API (6443/tcp) from 0.0.0.0/0
  - NodePort Services (30000-32767/tcp) from 0.0.0.0/0
  - HTTP (80/tcp) from 0.0.0.0/0
  - HTTPS (443/tcp) from 0.0.0.0/0
- **Outbound**: All traffic allowed

## Initialization Scripts

### jenkins-init.sh
- Installs Java 11 (required for Jenkins)
- Installs and starts Jenkins service
- Creates a completion marker file

### minikube-init.sh
- Installs Docker
- Installs kubectl
- Installs Minikube
- Installs virtualization tools (libvirt, qemu-kvm)
- Creates a completion marker file

## Free Tier Considerations

- **Instance Type**: t2.micro (eligible for AWS free tier)
- **Monthly Free Usage**: 750 hours of t2.micro instances per month
- **Networking**: No additional charges for VPC, public IPs, or data transfer within the module
- **Storage**: EBS storage charges may apply (20 GB free per month)

## Important Notes

1. **SSH Key Pair**: You must create an EC2 key pair and add it to the instance configuration before deployment
2. **Security**: The security groups allow SSH access from 0.0.0.0/0. Consider restricting this in production
3. **Initialization Time**: EC2 instances take 2-5 minutes to initialize with user data
4. **Monitoring**: Consider adding CloudWatch monitoring for production environments

## Accessing the Servers

### Jenkins Server
- **Access URL**: `http://<jenkins_public_ip>:8080`
- **SSH**: `ssh -i <key.pem> ec2-user@<jenkins_public_ip>`

### Minikube Server
- **SSH**: `ssh -i <key.pem> ec2-user@<minikube_public_ip>`
- **Kubernetes**: Configure kubectl to connect using the public IP

## Terraform Commands

```bash
# Initialize the module
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Destroy the resources
terraform destroy
```
