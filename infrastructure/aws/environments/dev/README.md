# AWS Development Environment

Complete Terraform configuration for the TerraSpan development environment on AWS.

## Overview

This development environment includes:
- **VPC**: A virtual private cloud with public and private subnets
- **EC2 Instances**: Two t2.micro instances for development purposes:
  - **Jenkins Server**: For continuous integration and continuous deployment (CI/CD)
  - **Minikube Server**: For local Kubernetes cluster development and testing
- **Security Groups**: Customized security groups for each server with appropriate access controls
- **Networking**: Internet gateway and route tables for proper traffic routing (free tier optimized)

## Architecture

```
AWS Development Environment (us-east-1)
│
├── VPC (10.0.0.0/16)
│   ├── Public Subnets
│   │   ├── Jenkins Server (t2.micro)
│   │   │   └── Security Group: SSH (22), Jenkins Web (8080)
│   │   └── Minikube Server (t2.micro)
│   │       └── Security Group: SSH (22), K8s API (6443), NodePort (30000-32767), HTTP/HTTPS (80/443)
│   │
│   └── Private Subnets
│       └── (Reserved for future services)
│
└── Internet Gateway
    └── Route Tables (Public & Private)
```

## Prerequisites

1. **AWS Account**: Active AWS account with appropriate permissions
2. **Terraform**: Version 1.5.0 or higher installed
3. **AWS CLI**: Configured with credentials
4. **EC2 Key Pair**: Created in the us-east-1 region (required for SSH access)

## File Structure

```
infrastructure/aws/
├── environments/
│   └── dev/
│       ├── main.tf              # Main configuration with module references
│       ├── variables.tf          # Variable definitions
│       ├── outputs.tf            # Output values
│       ├── terraform.tfvars      # Variable values (default)
│       └── README.md             # This file
│
└── modules/
    ├── networking/
    │   ├── main.tf              # VPC, subnets, IGW, route tables
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    │
    └── compute/
        ├── main.tf              # EC2 instances and security groups
        ├── variables.tf
        ├── outputs.tf
        ├── scripts/
        │   ├── jenkins-init.sh   # Jenkins installation script
        │   └── minikube-init.sh  # Minikube installation script
        └── README.md
```

## Deployment Instructions

### Step 1: Initialize Terraform

```bash
cd infrastructure/aws/environments/dev
terraform init
```

### Step 2: Review the Plan

```bash
terraform plan
```

This will show all the resources that will be created, including:
- 1 VPC
- 2 Public Subnets (across 2 AZs)
- 2 Private Subnets (across 2 AZs)
- Internet Gateway
- Route Tables and Associations
- 2 Security Groups (Jenkins & Minikube)
- 2 EC2 Instances (t2.micro)

### Step 3: Apply Configuration

```bash
terraform apply
```

When prompted, type `yes` to confirm the deployment.

### Step 4: Retrieve Output Values

After successful deployment, Terraform will display output values including:
- Jenkins Server Public IP
- Minikube Server Public IP
- Instance IDs
- Security Group IDs

```bash
terraform output
```

## Accessing the Servers

### Jenkins Server

1. **Web Interface**:
   ```
   http://<jenkins_public_ip>:8080
   ```

2. **Initial Setup**:
   - SSH into the server to retrieve the initial admin password:
     ```bash
     ssh -i <path-to-key.pem> ec2-user@<jenkins_public_ip>
     sudo cat /var/lib/jenkins/secrets/initialAdminPassword
     ```

3. **SSH Access**:
   ```bash
   ssh -i <path-to-key.pem> ec2-user@<jenkins_public_ip>
   ```

### Minikube Server

1. **SSH Access**:
   ```bash
   ssh -i <path-to-key.pem> ec2-user@<minikube_public_ip>
   ```

2. **Start Minikube** (after SSH):
   ```bash
   minikube start --driver=kvm2
   ```

3. **Check Kubernetes Status**:
   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

## Variables

Edit `terraform.tfvars` to customize:

| Variable | Default | Description |
|----------|---------|-------------|
| `project_name` | `terraspan` | Project identifier for naming resources |
| `environment` | `dev` | Environment name (dev, staging, prod) |
| `region` | `us-east-1` | AWS region |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `availability_zones` | `["us-east-1a", "us-east-1b"]` | Availability zones for redundancy |
| `instance_type` | `t2.micro` | EC2 instance type (must be t2.micro for free tier) |

## Outputs

After `terraform apply`, retrieve values using:

```bash
terraform output jenkins_public_ip
terraform output minikube_public_ip
```

## Security Considerations

⚠️ **Important**: The current security group configuration allows SSH and service ports from anywhere (`0.0.0.0/0`). For production:

1. **Restrict SSH Access**: Limit to specific IP addresses or VPN ranges
2. **Security Groups**: Add additional layer with Network ACLs
3. **Monitoring**: Enable CloudWatch monitoring and logging
4. **Backup**: Configure automated backups for persistent data

## Free Tier Optimization

This configuration is optimized for AWS free tier:

✅ **Free Tier Eligible**:
- VPC creation and management
- 2 t2.micro EC2 instances (750 hours/month each)
- 20 GB EBS storage (General Purpose gp2)
- Data transfer within AWS and limited internet egress

💰 **Potential Charges**:
- EBS snapshot storage (if enabled)
- Data transfer out of AWS (beyond 1 GB/month)
- Additional Elastic IPs (if not associated with running instances)

## Cleanup

To destroy all resources and avoid charges:

```bash
terraform destroy
```

When prompted, type `yes` to confirm deletion of all resources.

## Troubleshooting

### Issue: Terraform plan fails
- **Solution**: Ensure AWS CLI is configured with valid credentials
  ```bash
  aws sts get-caller-identity
  ```

### Issue: EC2 instances don't have internet access
- **Solution**: Verify public subnets have route to Internet Gateway
  ```bash
  aws ec2 describe-route-tables --region us-east-1
  ```

### Issue: Can't SSH to instances
- **Solution**: Check security group allows inbound SSH (port 22)
  ```bash
  aws ec2 describe-security-groups --region us-east-1
  ```

### Issue: Jenkins/Minikube not ready after deployment
- **Solution**: Wait 2-5 minutes for EC2 user data scripts to complete
  ```bash
  ssh -i <key.pem> ec2-user@<ip>
  tail -f /var/log/cloud-init-output.log
  ```

## Remote State Configuration

The backend is configured to use S3 for remote state management:

```hcl
backend "s3" {
  bucket  = "terraspan-terraform-state-706073863179"
  key     = "aws/dev/terraform.tfstate"
  region  = "us-east-1"
  encrypt = true
}
```

If the S3 bucket doesn't exist yet, comment out the backend block, run `terraform apply` to create it, then uncomment and run `terraform init` again.

## Next Steps

1. **Configure Jenkins**: Set up pipeline jobs and integrate with repositories
2. **Deploy Kubernetes Services**: Use Minikube to test containerized applications
3. **Add Monitoring**: Integrate CloudWatch or other monitoring solutions
4. **Implement CI/CD**: Connect Jenkins to version control systems
5. **Scale Infrastructure**: Add production and staging environments using similar modules

## Support and Documentation

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/)
- [AWS Free Tier Information](https://aws.amazon.com/free/)

## Maintenance

### Regular Tasks

1. **Security Updates**: Periodically update security groups and NACLs
2. **Backup**: Ensure critical data is backed up
3. **Cost Monitoring**: Check AWS billing dashboard for unexpected charges
4. **Updates**: Keep Jenkins and Kubernetes versions current

### Health Checks

```bash
# Check instances are running
aws ec2 describe-instances --region us-east-1

# Verify security groups
aws ec2 describe-security-groups --region us-east-1

# Check VPC configuration
aws ec2 describe-vpcs --region us-east-1
```
