# AWS Kubernetes Module

This module deploys a 2-node Kubernetes cluster on AWS with separate VPC and public subnet configuration.

## Overview

The module creates:
- A Kubernetes cluster with 1 master node and 1 worker node
- Both nodes run Ubuntu 22.04 LTS
- Master node: t2.medium (4GB RAM, 2 vCPU)
- Worker node: t3.small (2GB RAM, 2 vCPU)
- Complete security group with Kubernetes-specific ingress/egress rules
- Elastic IP for stable master node access

## Cost Optimization

- **t2.medium** for master: More feature-rich than t3, suitable for control plane
- **t3.small** for worker: Lower compute cost than t2, sufficient for workloads
- **gp3 volumes**: More cost-effective than gp2
- **Single AZ deployment**: Reduces data transfer costs
- **Public subnets**: Eliminates NAT gateway costs
- **Monitoring disabled**: Saves CloudWatch costs
- **Spot instances**: Can be used for worker nodes (manual modification)

## Architecture

```
┌─────────────────────────────────┐
│         VPC (10.0.0.0/16)       │
│                                 │
│  ┌───────────────────────────┐  │
│  │  Public Subnet            │  │
│  │  (10.0.0.0/24)            │  │
│  │                           │  │
│  │  ┌──────────────────────┐ │  │
│  │  │  Master Node         │ │  │
│  │  │  t2.medium           │ │  │
│  │  │  IP: 10.0.x.x        │ │  │
│  │  │  EIP: xxx.xxx.xxx.xx │ │  │
│  │  └──────────────────────┘ │  │
│  │                           │  │
│  │  ┌──────────────────────┐ │  │
│  │  │  Worker Node         │ │  │
│  │  │  t3.small            │ │  │
│  │  │  IP: 10.0.x.x        │ │  │
│  │  └──────────────────────┘ │  │
│  │                           │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

## Prerequisites

1. EC2 Key Pair created: `kubernetes-key-test`
2. AWS credentials configured
3. VPC and public subnet already created (via networking module)

## Variables

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| project_name | string | - | Yes | Project name for resource naming |
| environment | string | - | Yes | Environment (dev, staging, prod) |
| vpc_id | string | - | Yes | VPC ID where cluster will be deployed |
| vpc_cidr | string | - | Yes | VPC CIDR for security group rules |
| public_subnet_id | string | - | Yes | Public subnet ID for nodes |
| key_name | string | - | Yes | EC2 Key Pair name |
| master_instance_type | string | t2.medium | No | Master node instance type |
| worker_instance_type | string | t3.small | No | Worker node instance type |
| master_volume_size | number | 30 | No | Master node EBS volume size (GB) |
| worker_volume_size | number | 20 | No | Worker node EBS volume size (GB) |
| pod_network_cidr | string | 10.244.0.0/16 | No | Pod network CIDR (CNI) |
| tags | map(string) | {} | No | Common tags for resources |

## Outputs

- `master_id`: Master node instance ID
- `master_private_ip`: Master node private IP
- `master_public_ip`: Master node public IP
- `master_eip`: Master node Elastic IP (recommended for connection)
- `master_dns`: Master node public DNS name
- `worker_id`: Worker node instance ID
- `worker_private_ip`: Worker node private IP
- `worker_public_ip`: Worker node public IP
- `worker_dns`: Worker node public DNS name
- `security_group_id`: Kubernetes security group ID
- `kubernetes_cluster_name`: Cluster identifier

## Usage Example

```hcl
module "kubernetes" {
  source = "../../modules/kubernetes"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  vpc_cidr           = var.vpc_cidr
  public_subnet_id   = module.networking.public_subnet_ids[0]
  key_name           = var.key_name
  
  master_instance_type = "t2.medium"
  worker_instance_type = "t3.small"
  
  tags = local.common_tags
}
```

## Accessing the Cluster

### SSH to Master Node

```bash
ssh -i /path/to/kubernetes-key-test.pem ubuntu@<master_eip>
```

### Get Join Command for Worker Node

```bash
ssh -i /path/to/kubernetes-key-test.pem ubuntu@<master_eip>
sudo cat /root/kubernetes_join_command.sh
```

### Copy Join Command to Worker Node

```bash
ssh -i /path/to/kubernetes-key-test.pem ubuntu@<worker_public_ip>
sudo bash -c "$(cat << 'EOF'
<paste_join_command_here>
EOF
)"
```

### Verify Cluster Status

```bash
ssh -i /path/to/kubernetes-key-test.pem ubuntu@<master_eip>
kubectl get nodes
kubectl get pods --all-namespaces
```

## Security Considerations

### Ingress Rules

- SSH (22): Open to 0.0.0.0/0 (restrict this in production)
- Kubernetes API (6443): VPC CIDR only
- Kubelet API (10250): VPC CIDR only
- etcd (2379-2380): VPC CIDR only
- CNI (4789/UDP): VPC CIDR only
- NodePort (30000-32767): Open to 0.0.0.0/0

### Recommendations for Production

1. Restrict SSH access to specific IPs
2. Place nodes in private subnets with NAT gateway
3. Use Network Load Balancer (NLB) for API access
4. Enable EBS encryption
5. Enable detailed monitoring
6. Use RDS for persistent storage instead of local volumes
7. Implement pod security policies
8. Use RBAC for access control

## Cluster Components

### Master Node Services
- kube-apiserver: API server for cluster management
- kube-controller-manager: Controllers for cluster management
- kube-scheduler: Pod scheduling
- etcd: Cluster data store
- kubelet: Node agent
- Docker: Container runtime

### Worker Node Services
- kubelet: Node agent
- kube-proxy: Network proxy and load balancer
- Docker: Container runtime
- CNI (Flannel): Pod networking

## Network Architecture

### Port Mappings

| Port | Protocol | Component | Usage |
|------|----------|-----------|-------|
| 6443 | TCP | kube-apiserver | Kubernetes API |
| 2379-2380 | TCP | etcd | etcd server client API |
| 10250 | TCP | kubelet | kubelet API |
| 10251 | TCP | kube-scheduler | Scheduler health check |
| 10252 | TCP | kube-controller-manager | Controller manager health check |
| 4789 | UDP | Flannel | VXLAN overlay network |
| 30000-32767 | TCP | NodePort | Node port services |

## Troubleshooting

### Nodes not joining cluster
1. Check security group rules
2. Verify VPC connectivity
3. Check `/var/log/cloud-init-output.log` on each node
4. Verify DNS resolution

### Pods not starting
1. Check CNI plugin status: `kubectl get daemonset -n kube-system`
2. Check node status: `kubectl get nodes -o wide`
3. Check event logs: `kubectl describe pod <pod-name> -n <namespace>`

### API server not accessible
1. Verify master node is running
2. Check security group allows port 6443
3. Verify network connectivity from client
4. Check kube-apiserver logs: `kubectl logs -n kube-system -l component=kube-apiserver`

## Cost Estimates (Monthly - ap-south-1)

- Master node (t2.medium, on-demand): ~$0.0464/hour = ~$34/month
- Worker node (t3.small, on-demand): ~$0.0208/hour = ~$15/month
- EBS volumes (50GB gp3, assuming 3 IOPS/GB): ~$4/month
- Total: ~$53/month for on-demand pricing

**To reduce costs further:**
- Use Spot instances for worker nodes (~70% savings)
- Combine with AWS free tier if account is new
- Use shared networking resources

## Files

- `main.tf`: Main Kubernetes infrastructure resources
- `variables.tf`: Input variables
- `outputs.tf`: Output values
- `scripts/master-init.sh`: Master node initialization script
- `scripts/worker-init.sh`: Worker node initialization script
