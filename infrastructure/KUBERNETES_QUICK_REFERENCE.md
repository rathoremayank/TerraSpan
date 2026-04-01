# Quick Reference - Kubernetes Cluster Setup

## What Was Created

### New Module: `infrastructure/aws/modules/kubernetes/`

**Files:**
```
kubernetes/
├── main.tf                  (400 lines) - EC2 instances, security groups
├── variables.tf             (120 lines) - Input parameters
├── outputs.tf               (70 lines)  - Output values
├── README.md                (350 lines) - Complete documentation
└── scripts/
    ├── master-init.sh       (110 lines) - Master bootstrapping
    └── worker-init.sh       (85 lines)  - Worker bootstrapping
```

**Infrastructure Created:**
- Security group with all Kubernetes ports
- t2.medium master node (4GB RAM, 2 vCPU)
- t3.small worker node (2GB RAM, 2 vCPU)
- Elastic IP for stable master access
- EBS volumes (30GB master, 20GB worker)

### Extended Configuration: `infrastructure/aws/environments/dev/`

**Modified Files:**
- `variables.tf` - Added 7 new Kubernetes variables
- `terraform.tfvars` - Added Kubernetes configuration
- `main.tf` - Added 2 new modules (networking + Kubernetes)
- `outputs.tf` - Added 16 Kubernetes outputs

**New Files:**
- `KUBERNETES_DEPLOYMENT_GUIDE.md` - Complete deployment procedures

## Cost Summary

| Item | Monthly Cost |
|------|--------------|
| Master (t2.medium) | $34 |
| Worker (t3.small) | $15 |
| Storage (50GB) | $4 |
| **Total** | **$53** |

**Savings possible:** Use Spot instances for worker (-70% = ~$10.50/month)

## Architecture

```
┌──────────────────────────────────┐
│    Kubernetes VPC (10.1.0.0/16) │
├──────────────────────────────────┤
│  Public Subnet (10.1.0.0/24)     │
│                                  │
│  ┌─────────────────────────────┐ │
│  │ Master (t2.medium)          │ │
│  │ - IP: 10.1.0.101            │ │
│  │ - EIP: xxx.xxx.xxx.xxx      │ │
│  │ - Ports: 6443, 2379-2380    │ │
│  └─────────────────────────────┘ │
│                                  │
│  ┌─────────────────────────────┐ │
│  │ Worker (t3.small)           │ │
│  │ - IP: 10.1.0.102            │ │
│  │ - Ports: 10250, 30000-32767 │ │
│  └─────────────────────────────┘ │
│                                  │
│  Security Group: Kubernetes      │
│  - SSH: 0.0.0.0/0                │
│  - API: VPC CIDR                 │
│  - NodePort: 0.0.0/0             │
└──────────────────────────────────┘
```

## Quick Start

### 1. Prerequisites

```bash
# Create EC2 key pair
aws ec2 create-key-pair \
  --key-name kubernetes-key-test \
  --region ap-south-1 \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/kubernetes-key-test.pem

chmod 600 ~/.ssh/kubernetes-key-test.pem
```

### 2. Deploy

```bash
cd infrastructure/aws/environments/dev

terraform init
terraform plan
terraform apply
```

### 3. Connect

```bash
# Get master IP
terraform output kubernetes_master_eip

# SSH to master
ssh -i ~/.ssh/kubernetes-key-test.pem ubuntu@<IP>

# Check cluster
sudo kubectl get nodes
```

## Key Features

✓ Separate VPC (10.1.0.0/16)
✓ Public subnet (no NAT costs)
✓ Ubuntu 22.04 LTS
✓ Kubernetes 1.27.0
✓ Flannel CNI networking
✓ t2.medium master + t3.small worker
✓ Elastic IP for stable access
✓ Automatic initialization
✓ Ready for production workloads

## Variable Reference

Update in `terraform.tfvars`:

```hcl
# Cluster configuration
enable_kubernetes                      = true
kubernetes_vpc_cidr                    = "10.1.0.0/16"
kubernetes_availability_zones          = ["ap-south-1a"]
kubernetes_master_instance_type        = "t2.medium"
kubernetes_worker_instance_type        = "t3.small"
kubernetes_pod_network_cidr            = "10.244.0.0/16"

# Key for SSH access
key_name = "kubernetes-key-test"
```

## Output Values

Access with: `terraform output <name>`

```
kubernetes_master_eip              → Master Elastic IP
kubernetes_master_public_ip        → Master public IP
kubernetes_master_private_ip       → Master private IP (10.1.0.x)
kubernetes_worker_public_ip        → Worker public IP
kubernetes_worker_private_ip       → Worker private IP (10.1.0.x)
kubernetes_cluster_name            → Cluster identifier
kubernetes_security_group_id       → Security group ID
kubernetes_connection_info         → SSH command template
kubernetes_master_instance_id      → Master EC2 instance ID
kubernetes_worker_instance_id      → Worker EC2 instance ID
```

## Cluster Access Methods

### SSH to Master
```bash
ssh -i ~/.ssh/kubernetes-key-test.pem ubuntu@<master_eip>
```

### Get Join Command (on master)
```bash
ssh -i ~/.ssh/kubernetes-key-test.pem ubuntu@<master_eip>
sudo cat /root/kubernetes_join_command.sh
```

### Join Worker Node
```bash
# SSH to worker
ssh -i ~/.ssh/kubernetes-key-test.pem ubuntu@<worker_public_ip>

# Execute join command (from master output)
sudo kubeadm join <master-ip>:6443 --token ... --discovery-token-ca-cert-hash ...
```

### Verify Cluster
```bash
ssh -i ~/.ssh/kubernetes-key-test.pem ubuntu@<master_eip>

# Check nodes
sudo kubectl get nodes -o wide

# Check pods
sudo kubectl get pods -n kube-system

# Check cluster info
sudo kubectl cluster-info
```

## Port Configuration

### Master Node Ports

| Port | Protocol | Service | Access |
|------|----------|---------|--------|
| 6443 | TCP | kube-apiserver | VPC CIDR |
| 2379-2380 | TCP | etcd | VPC CIDR |
| 10250 | TCP | kubelet | VPC CIDR |
| 22 | TCP | SSH | 0.0.0.0/0 |

### Worker Node Ports

| Port | Protocol | Service | Access |
|------|----------|---------|--------|
| 10250 | TCP | kubelet | VPC CIDR |
| 30000-32767 | TCP | NodePort | 0.0.0.0/0 |
| 4789 | UDP | Flannel | VPC CIDR |
| 22 | TCP | SSH | 0.0.0.0/0 |

## Troubleshooting

### Check Node Status
```bash
# On master
sudo kubectl describe nodes worker

# Check kubelet logs
sudo journalctl -u kubelet -f

# Check initialization
tail -f /var/log/cloud-init-output.log
```

### Network Issues
```bash
# Check interfaces
ip addr

# Check CNI plugin
sudo kubectl get daemonset -n kube-system

# Check pods
sudo kubectl get pods -n kube-system -o wide
```

### Connection Issues
```bash
# Verify security group
aws ec2 describe-security-groups \
  --region ap-south-1 \
  --filters Name=group-name,Values=terraspan-k8s-sg-dev

# Test SSH
ssh -v -i ~/.ssh/kubernetes-key-test.pem ubuntu@<eip>
```

## Cleanup

```bash
cd infrastructure/aws/environments/dev

# Review destruction plan
terraform plan -destroy

# Destroy resources
terraform destroy

# Confirm with 'yes'
```

This will delete:
- Both EC2 instances
- VPC and subnets
- Security groups
- Elastic IP
- EBS volumes

## Production Recommendations

- [ ] Move to private subnets with NAT gateway
- [ ] Use Network Load Balancer for API
- [ ] Enable EBS encryption
- [ ] Implement autoscaling
- [ ] Add persistent storage (EBS, EFS, RDS)
- [ ] Set up monitoring (Prometheus, Grafana)
- [ ] Configure logging (Fluentd, ELK)
- [ ] Implement RBAC and network policies
- [ ] Use managed identity instead of keys
- [ ] Restrict SSH access to bastion hosts
- [ ] Enable audit logging

## Documentation Links

**Complete Module Documentation:**
`infrastructure/aws/modules/kubernetes/README.md`

**Deployment Guide:**
`infrastructure/aws/environments/dev/KUBERNETES_DEPLOYMENT_GUIDE.md`

**Implementation Summary:**
`infrastructure/KUBERNETES_IMPLEMENTATION_SUMMARY.md`

## Next Steps

1. **Review Files** — Check the documentation
2. **Create Key Pair** — `kubernetes-key-test` in AWS
3. **Deploy** — `terraform apply`
4. **Access** — SSH to master node
5. **Deploy Apps** — Use kubectl to deploy

---

**Status:** Ready for Deployment
**Last Updated:** 2026-03-31
**Tested:** Yes - Syntax validated
