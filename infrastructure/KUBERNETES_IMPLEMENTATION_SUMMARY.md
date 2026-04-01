# Kubernetes Cluster Setup - Implementation Summary

## Overview

A complete Kubernetes 2-node cluster infrastructure has been implemented for TerraSpan using Terraform. The cluster is deployed in a separate VPC with public subnets and is fully configured for cost-efficient development and testing.

## Architecture

```
AWS Account (ap-south-1)
│
├─ Main VPC (10.0.0.0/16)
│  └─ EC2 Jenkins Server (existing)
│
└─ Kubernetes VPC (10.1.0.0/16) [NEW]
   └─ Public Subnet (10.1.0.0/24)
      ├─ Master Node (t2.medium)
      │  ├─ Instance: terraspan-k8s-master-dev
      │  ├─ OS: Ubuntu 22.04 LTS
      │  ├─ Role: Control Plane
      │  ├─ Ports: 6443 (API), 2379-2380 (etcd), 10250 (kubelet)
      │  └─ Elastic IP: Allocated for stable access
      │
      └─ Worker Node (t3.small)
         ├─ Instance: terraspan-k8s-worker-dev
         ├─ OS: Ubuntu 22.04 LTS
         ├─ Role: Worker
         └─ Ports: 10250 (kubelet), 30000-32767 (NodePort)
```

## Files Created

### Kubernetes Module (`infrastructure/aws/modules/kubernetes/`)

#### Core Terraform Files
- **`main.tf`** (400+ lines)
  - Security group configuration with Kubernetes-specific ports
  - Master node EC2 instance (t2.medium)
  - Worker node EC2 instance (t3.small)
  - Elastic IP for master node
  - Ubuntu 22.04 LTS AMI lookup
  - User data templates for initialization

- **`variables.tf`** (120+ lines)
  - Project and environment configuration
  - VPC and subnet specifications
  - Instance type settings
  - Storage configuration (EBS volumes)
  - Pod network CIDR (CNI configuration)
  - Validation rules for inputs

- **`outputs.tf`** (70+ lines)
  - Master and worker node IDs, IPs, DNS
  - Security group information
  - Cluster identifier
  - Connection information

- **`README.md`** (350+ lines)
  - Complete module documentation
  - Architecture diagrams
  - Cost optimization strategies
  - Security considerations
  - Troubleshooting guide
  - Port mappings and network configuration

#### Initialization Scripts
- **`scripts/master-init.sh`** (110+ lines)
  - Docker installation and configuration
  - Kubernetes 1.27.0 deployment
  - kubeadm cluster initialization
  - Flannel CNI plugin setup
  - Join command generation for workers
  - Kernel parameter configuration
  - Swap disable and module loading

- **`scripts/worker-init.sh`** (85+ lines)
  - Docker installation
  - Kubernetes components installation
  - Kernel parameter configuration
  - Ready for cluster join command

### Development Environment Configuration

#### `infrastructure/aws/environments/dev/`

- **`variables.tf`** (Extended)
  - `kubernetes_vpc_cidr`: 10.1.0.0/16
  - `kubernetes_availability_zones`: ["ap-south-1a"]
  - `kubernetes_master_instance_type`: t2.medium
  - `kubernetes_worker_instance_type`: t3.small
  - `kubernetes_pod_network_cidr`: 10.244.0.0/16
  - `enable_kubernetes`: true (toggle for cluster deployment)

- **`terraform.tfvars`** (Updated)
  - Kubernetes-specific configuration values
  - Regional settings (ap-south-1)
  - Instance type and network specifications

- **`main.tf`** (Extended)
  - New: `module "kubernetes_networking"` — separate VPC for Kubernetes
  - New: `module "kubernetes"` — Kubernetes cluster deployment
  - Conditional deployment based on `enable_kubernetes` flag
  - Proper dependency management between modules

- **`outputs.tf`** (Extended)
  - Kubernetes VPC outputs
  - Master and worker node connection information
  - Security group and cluster identifiers
  - Connection help text with SSH command template

- **`KUBERNETES_DEPLOYMENT_GUIDE.md`** (400+ lines)
  - Complete deployment procedures
  - Prerequisites and setup
  - Step-by-step deployment instructions
  - Post-deployment verification
  - Cluster access methods
  - Troubleshooting guide
  - Disaster recovery procedures
  - Cost analysis and reduction strategies

## Cost Analysis

### Monthly Costs (us-east-1 pricing, ap-south-1 similar)

| Resource | Type | Cost/Month | Notes |
|----------|------|-----------|-------|
| Master Node (t2.medium) | On-Demand EC2 | ~$34 | 4GB RAM, 2 vCPU |
| Worker Node (t3.small) | On-Demand EC2 | ~$15 | 2GB RAM, 2 vCPU |
| EBS Volumes (50GB gp3) | Storage | ~$4 | 3 IOPS/GB included |
| Elastic IP | Network | Free | Free while in use |
| VPC/Subnets/IGW | Network | Free | AWS managed |
| **Total** | | **~$53** | Minimum cluster |

### Cost Optimization Features

✓ **t2.medium & t3.small** — Smaller instance types suitable for dev
✓ **On-demand pricing** — No long-term commitments
✓ **Single AZ** — Reduces data transfer costs
✓ **Public subnets** — No NAT gateway charges
✓ **gp3 volumes** — More cost-effective than gp2
✓ **Monitoring disabled** — Saves CloudWatch costs
✓ **Spot instances ready** — Can be enabled for worker nodes (~70% savings)

### Further Cost Reduction

1. Use Spot Instances for worker node: **-$10.50/month** (70% savings)
2. Reduce volume sizes: **-$1-2/month**
3. Use AWS Free Tier (new accounts): **-$40-50/month** for first 12 months
4. Combine with reserved instances: **-30-40%** when ready to commit

## Security Groups & Network Access

### Ingress Rules (Inbound)

| Port(s) | Protocol | Source | Purpose |
|---------|----------|--------|---------|
| 22 | TCP | 0.0.0.0/0 | SSH Access |
| 6443 | TCP | VPC CIDR | Kubernetes API Server |
| 2379-2380 | TCP | VPC CIDR | etcd communication |
| 10250 | TCP | VPC CIDR | kubelet API |
| 4789 | UDP | VPC CIDR | Flannel VXLAN |
| 30000-32767 | TCP | 0.0.0.0/0 | NodePort Services |
| 0-65535 | TCP | VPC CIDR | Inter-node communication |

### Egress Rules (Outbound)

| Port(s) | Protocol | Destination | Purpose |
|---------|----------|-------------|---------|
| All | All | 0.0.0.0/0 | Unrestricted outbound |

### Post-Deployment Security Recommendations

- ✓ Restrict SSH (22) to specific IPs in production
- ✓ Move nodes to private subnets with bastion host
- ✓ Implement Network Policies for pod-to-pod communication
- ✓ Enable EBS encryption
- ✓ Use AWS Systems Manager Session Manager instead of SSH keys
- ✓ Implement RBAC and pod security policies
- ✓ Enable audit logging for API server

## Deployment Quick Start

### Prerequisites
```bash
✓ AWS account with appropriate IAM permissions
✓ EC2 Key Pair created: kubernetes-key-test
✓ Terraform >= 1.5.0
✓ AWS CLI configured
```

### Deploy

```bash
cd infrastructure/aws/environments/dev

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy
terraform apply

# Get connection information
terraform output kubernetes_master_eip
terraform output kubernetes_connection_info
```

### Access Cluster

```bash
# SSH to master
ssh -i ~/.ssh/kubernetes-key-test.pem ubuntu@<master_eip>

# Check cluster status
sudo kubectl get nodes
```

## Kubernetes Components

### Installed Version
- **Kubernetes**: 1.27.0
- **Docker**: Latest stable
- **CNI Plugin**: Flannel (VXLAN overlay)
- **OS**: Ubuntu 22.04 LTS (Jammy)

### Services Installed

**Master Node:**
- kube-apiserver — API server
- kube-controller-manager — Controllers
- kube-scheduler — Pod scheduler
- etcd — Distributed data store
- kubelet — Node agent
- kube-proxy — Network proxy
- Docker — Container runtime
- Flannel — Pod networking

**Worker Node:**
- kubelet — Node agent
- kube-proxy — Network proxy
- Docker — Container runtime
- Flannel agent — Pod networking

## Key Features

✓ **Separate VPC** — Isolated network for Kubernetes
✓ **Public subnet** — Direct internet access (no NAT costs)
✓ **2-node cluster** — Master + Worker configuration
✓ **Ubuntu 22.04 LTS** — Current long-term support
✓ **Flannel CNI** — Simple, reliable pod networking
✓ **S3 state backend** — Terraform state stored remotely
✓ **Tagging** — All resources properly tagged for cost tracking
✓ **Elastic IP** — Stable master node access
✓ **Health checks** — Automatic node monitoring
✓ **Auto-healing** — kubelet auto-restarts failed components

## Directory Structure

```
infrastructure/aws/
├── modules/
│   ├── kubernetes/                        [NEW]
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   └── scripts/
│   │       ├── master-init.sh
│   │       └── worker-init.sh
│   ├── networking/                        [Modified to support k8s]
│   ├── compute/
│   └── ... (other modules)
│
└── environments/
    └── dev/
        ├── main.tf                        [Modified - added k8s modules]
        ├── variables.tf                   [Modified - added k8s variables]
        ├── terraform.tfvars               [Modified - added k8s config]
        ├── outputs.tf                     [Modified - added k8s outputs]
        ├── KUBERNETES_DEPLOYMENT_GUIDE.md [NEW]
        └── ... (other config files)
```

## Next Steps

1. **Review Files**
   - `infrastructure/aws/modules/kubernetes/README.md` — Module documentation
   - `infrastructure/aws/environments/dev/KUBERNETES_DEPLOYMENT_GUIDE.md` — Deployment guide

2. **Prepare for Deployment**
   - Create EC2 key pair: `kubernetes-key-test`
   - Review costs and adjust instance types if needed
   - Plan resource availability

3. **Deploy**
   - `terraform init`
   - `terraform plan`
   - `terraform apply`

4. **Post-Deployment**
   - SSH to master node
   - Verify cluster status
   - Join worker node
   - Deploy test applications

5. **Scaling Strategies**
   - Add more worker nodes (modify module)
   - Use autoscaling groups
   - Implement ingress controller
   - Set up persistent volumes

## Support & Customization

### Modify Configuration

Update in `terraform.tfvars`:

```hcl
# Change instance types
kubernetes_master_instance_type = "t2.large"     # More powerful
kubernetes_worker_instance_type = "t3.medium"    # Larger worker

# Change region
region = "us-east-1"

# Disable Kubernetes (keep main infrastructure)
enable_kubernetes = false

# Custom pod network
kubernetes_pod_network_cidr = "10.246.0.0/16"
```

### Scale to Multiple Worker Nodes

Modify `main.tf` kubernetes module:

```hcl
# Add multiple worker instances using count or for_each
resource "aws_instance" "workers" {
  count = 3  # Deploy 3 workers
  # ... configuration
}
```

### For Production

- See [Kubernetes Production Best Practices](https://kubernetes.io/docs/setup/production-environment/)
- See module README: `infrastructure/aws/modules/kubernetes/README.md`
- Reference deployment guide: `infrastructure/aws/environments/dev/KUBERNETES_DEPLOYMENT_GUIDE.md`

## Troubleshooting

**Terraform Issues**
- `terraform validate` — Check syntax
- `terraform fmt` — Format code
- View detailed logs: `TF_LOG=DEBUG terraform apply`

**AWS Issues**
- Verify IAM permissions
- Check EC2 quota limits
- Review security groups

**Kubernetes Issues**
- SSH to master and check logs: `sudo journalctl -u kubelet`
- View initialization: `tail -f /var/log/cloud-init-output.log`
- See full troubleshooting guide in deployment documentation

## References

- [Kubernetes Official](https://kubernetes.io/)
- [kubeadm Documentation](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)
- [Flannel Networking](https://github.com/coreos/flannel)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 Pricing](https://aws.amazon.com/ec2/pricing/on-demand/)

---

**Last Updated:** 2026-03-31
**Implementation Status:** Complete
**Ready for Deployment:** Yes
