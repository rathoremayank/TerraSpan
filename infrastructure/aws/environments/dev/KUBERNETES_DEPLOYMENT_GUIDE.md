# Kubernetes Cluster Deployment Guide

This guide provides step-by-step instructions for deploying and managing the Kubernetes cluster in the development environment.

## Files Overview

- `main.tf`: Main Terraform configuration with module definitions
- `variables.tf`: Input variables with defaults
- `terraform.tfvars`: Variable values for the development environment
- `outputs.tf`: Output values for cluster access information

## Prerequisites

### 1. AWS Account Setup
- AWS account with appropriate permissions
- AWS CLI configured with credentials
- Terraform >= 1.5.0 installed

### 2. EC2 Key Pair
Create an EC2 key pair named `kubernetes-key-test`:

```bash
aws ec2 create-key-pair \
  --key-name kubernetes-key-test \
  --region ap-south-1 \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/kubernetes-key-test.pem

chmod 600 ~/.ssh/kubernetes-key-test.pem
```

Alternatively, create through AWS Console:
- EC2 → Key Pairs → Create key pair
- Name: `kubernetes-key-test`
- File format: PEM
- Download and save to `~/.ssh/kubernetes-key-test.pem`

### 3. Terraform Backend
Ensure the S3 bucket for state exists or disable the backend:
```bash
# Option 1: Create the bucket
aws s3 mb s3://terraspan-terraform-state-706073863179 --region ap-south-1

# Option 2: Disable remote state in main.tf
# Comment out the backend "s3" block temporarily
```

## Deployment Steps

### Step 1: Initialize Terraform

```bash
cd infrastructure/aws/environments/dev
terraform init
```

### Step 2: Review Configuration

```bash
terraform fmt
terraform validate
```

### Step 3: Plan Deployment

```bash
terraform plan -out=tfplan
```

**Key resources to be created:**
- VPC for Kubernetes (10.1.0.0/16)
- Public subnet (10.1.0.0/24)
- Internet Gateway
- Route tables
- Security group with Kubernetes ports
- t2.medium EC2 instance (master)
- t3.small EC2 instance (worker)
- Elastic IP for master

### Step 4: Apply Configuration

```bash
terraform apply tfplan
```

Expected output includes:
```
Apply complete! Resources added: 25, changed: 0, destroyed: 0

Outputs:
kubernetes_cluster_name = "terraspan-k8s-dev"
kubernetes_master_eip = "XX.XX.XX.XX"
kubernetes_master_private_ip = "10.1.0.101"
kubernetes_worker_public_ip = "10.1.0.102"
kubernetes_connection_info = "SSH to master: ssh -i ~/.ssh/kubernetes-key-test.pem ubuntu@XX.XX.XX.XX"
```

### Step 5: Access Master Node

```bash
ssh -i ~/.ssh/kubernetes-key-test.pem ubuntu@<kubernetes_master_eip>
```

Example:
```bash
ssh -i ~/.ssh/kubernetes-key-test.pem ubuntu@203.0.113.50
```

### Step 6: Monitor Cluster Initialization

On the master node, check cluster status:

```bash
# Check node status
sudo kubectl get nodes

# Watch cluster initialization (may take 2-3 minutes)
watch -n 1 'sudo kubectl get nodes'

# Check system pods
sudo kubectl get pods -n kube-system

# View master node logs
tail -f /var/log/cloud-init-output.log

# Get join command for worker
sudo cat /root/kubernetes_join_command.sh
```

### Step 7: Join Worker Node

SSH to the worker node:

```bash
ssh -i ~/.ssh/kubernetes-key-test.pem ubuntu@<kubernetes_worker_public_ip>
```

On the worker node:

```bash
# For development/testing, you can SSH from master to worker:
# On master node:
scp /root/kubernetes_join_command.sh ubuntu@<worker-private-ip>:/tmp/

# Then SSH to worker and execute:
ssh ubuntu@<worker-private-ip>
sudo bash /tmp/kubernetes_join_command.sh
```

Or manually on worker:

```bash
# Get the join command from master node logs
# The format is:
sudo kubeadm join <master-private-ip>:6443 \
  --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>
```

### Step 8: Verify Cluster Setup

On the master node:

```bash
# Check all nodes are ready
sudo kubectl get nodes -o wide

# Expected output:
# NAME    STATUS   ROLES           AGE     VERSION
# master  Ready    control-plane   5m      v1.27.0
# worker  Ready    <none>          2m      v1.27.0

# Check CNI (Flannel) pods
sudo kubectl get pods -n kube-system -l app=flannel

# Check all system pods are running
sudo kubectl get pods -n kube-system

# Check cluster info
sudo kubectl cluster-info

# Check kubelet status
sudo systemctl status kubelet
```

## Cluster Access Methods

### Local Machine Setup

On your local machine, copy the kubeconfig from master:

```bash
mkdir -p ~/.kube
scp -i ~/.ssh/kubernetes-key-test.pem \
  ubuntu@<kubernetes_master_eip>:/home/ubuntu/.kube/config \
  ~/.kube/config-k8s-dev

# Set environment variable
export KUBECONFIG=$HOME/.kube/config-k8s-dev

# Verify connection
kubectl get nodes
```

### Deploy Test Application

```bash
# Create a simple nginx deployment
kubectl create deployment nginx --image=nginx

# Expose the deployment
kubectl expose deployment nginx --port=80 --type=NodePort

# Get the NodePort service
kubectl get svc nginx

# Access from browser or curl (using master EIP and NodePort)
curl http://<kubernetes_master_eip>:<node_port>
```

## Cost Optimization Summary

| Component | Type | Cost/Hour | Cost/Month |
|-----------|------|-----------|-----------|
| Master Node (t2.medium) | On-demand | $0.0464 | ~$34 |
| Worker Node (t3.small) | On-demand | $0.0208 | ~$15 |
| EBS Storage (50GB gp3) | Storage | - | ~$4 |
| Elastic IP (master) | Static IP | - | Free (if in use) |
| **Total** | | | **~$53/month** |

### Cost Reduction Strategies

1. **Use Spot Instances for Worker**
   ```hcl
   # Modify kubernetes module instantiation in main.tf
   # Use instance_interruption_behavior = "stop"
   ```
   Savings: ~70% on worker node (~$4.50/month)

2. **Reduce Volume Size**
   - Master: 20GB (minimum)
   - Worker: 15GB (minimum for basic workloads)

3. **Use Free Tier Credits** (if eligible)
   - 750 hours/month of t2.micro (not enough for this setup)
   - Good for testing before scaling

## Troubleshooting

### Nodes Not Ready

Check node status details:
```bash
sudo kubectl describe nodes worker
```

Common issues:
1. Network plugin not installed — it installs automatically via cloud-init
2. Insufficient resources — ensure t3.small has 2GB RAM available
3. kubelet not running — check systemctl status kubelet

### Getting Cluster Logs

On each node:
```bash
# Cloud-init logs
tail -f /var/log/cloud-init-output.log

# Kubelet logs
journalctl -u kubelet -f

# Docker logs
sudo docker logs <container_id>

# Kubernetes API server logs (master only)
sudo kubectl logs -n kube-system -l component=kube-apiserver
```

### Network Connectivity Issues

Verify security group rules:
```bash
# From local machine
# The security group is open for:
# - SSH (22): 0.0.0.0/0
# - Kubernetes API (6443): VPC CIDR
# - NodePort (30000-32767): 0.0.0.0/0
# - Inter-node traffic: VPC CIDR
```

Check pods network:
```bash
# On any node
ip addr  # Check flannel interface (usually 10.244.x.x)
sudo ip link show  # Check cni0 and flannel.1 interfaces
```

### SSH Connection Issues

```bash
# Verify key permissions
ls -la ~/.ssh/kubernetes-key-test.pem
# Should be: -rw------- (600)

# Test SSH connection
ssh -v -i ~/.ssh/kubernetes-key-test.pem ubuntu@<eip>

# Common issues:
# 1. Wrong key file — verify key pair name matches
# 2. Security group doesn't allow port 22 — should be open for 0.0.0.0/0
# 3. Instance still initializing — wait 2-3 minutes
```

## Disaster Recovery

### Backup etcd Database

```bash
ssh -i ~/.ssh/kubernetes-key-test.pem ubuntu@<kubernetes_master_eip>

sudo kubectl exec -n kube-system -it etcd-$(hostname) -- \
  env ETCDCTL_API=3 ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
  ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
  ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
  etcdctl snapshot save /tmp/etcd-backup-$(date +%Y%m%d-%H%M%S).db
```

### Restore from Backup

```bash
# This requires restarting the cluster — only use for recovery scenarios
sudo etcdctl snapshot restore <backup-file> \
  --data-dir=/var/lib/etcd-restored
```

## Cleanup and Destruction

### Remove Kubernetes Cluster

```bash
cd infrastructure/aws/environments/dev

# Review what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Confirm with 'yes' when prompted
```

**Note:** This will delete:
- Both EC2 instances
- VPC and subnets
- Security groups
- Elastic IP
- All EBS volumes

## Next Steps

### For Production

1. Move to private subnets with NAT gateway
2. Use Network Load Balancer (NLB) for API
3. Implement autoscaling
4. Add persistent storage (EBS, EFS, or RDS)
5. Implement monitoring (Prometheus, Grafana)
6. Set up logging (Fluentd, ELK)
7. Implement RBAC and network policies
8. Use managed identity credentials instead of keys

### For Development/Testing

1. Deploy test applications
2. Learn Kubernetes concepts
3. Practice cluster management
4. Test CI/CD integration
5. Experiment with different workloads

## Quick Reference

### Terraform Commands

```bash
# Initialize
terraform init

# Validate
terraform validate

# Format
terraform fmt

# Plan
terraform plan

# Apply
terraform apply

# Output values
terraform output

# Destroy
terraform destroy

# Target specific resource
terraform apply -target=module.kubernetes
```

### Kubernetes Commands (on master node)

```bash
# Cluster info
sudo kubectl cluster-info
sudo kubectl get nodes
sudo kubectl get nodes -o wide

# Namespaces and pods
sudo kubectl get ns
sudo kubectl get pods -n kube-system
sudo kubectl get pods -n kube-system -o wide

# Describe resources
sudo kubectl describe node worker
sudo kubectl describe pod <pod-name> -n kube-system

# Logs
sudo kubectl logs -n kube-system -l app=flannel
sudo kubectl logs -n kube-system pod/kube-apiserver-master

# Services
sudo kubectl get svc
sudo kubectl get svc -n kube-system
```

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubeadm Reference](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)
- [Flannel Documentation](https://github.com/coreos/flannel)
- [AWS EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
