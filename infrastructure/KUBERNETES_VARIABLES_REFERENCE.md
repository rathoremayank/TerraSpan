# Kubernetes Configuration - Variables Reference

This document provides a complete reference for all Kubernetes-related variables in the TerraSpan infrastructure.

## Development Environment Variables

Location: `infrastructure/aws/environments/dev/terraform.tfvars`

### Kubernetes Deployment Control

```hcl
enable_kubernetes = true
```

**Purpose:** Toggle to enable/disable the entire Kubernetes cluster deployment
**Type:** boolean
**Default:** true
**Impact:** 
- `true` → Creates Kubernetes VPC, master, and worker nodes
- `false` → Skips Kubernetes resource creation
- Use `false` for cost savings when not needed

---

### Kubernetes VPC Configuration

```hcl
kubernetes_vpc_cidr = "10.1.0.0/16"
```

**Purpose:** CIDR block for the Kubernetes VPC
**Type:** string
**Default:** "10.1.0.0/16"
**Constraints:**
- Must be valid CIDR notation
- Should not overlap with main VPC (10.0.0.0/16)
- Provides 65,536 IP addresses
- Public subnet uses: 10.1.0.0/24 (256 IPs)
- Can support additional private subnets if extended

**IP Address Breakdown:**
```
10.1.0.0/16       - Full VPC (65,536 addresses)
  └─ 10.1.0.0/24  - Public subnet (256 addresses)
      ├─ 10.1.0.1        - VPC router
      ├─ 10.1.0.2        - DNS
      ├─ 10.1.0.3        - Reserved
      ├─ 10.1.0.4        - Reserved
      ├─ 10.1.0.101      - Master node
      ├─ 10.1.0.102      - Worker node
      └─ ...
```

---

### Kubernetes Availability Zones

```hcl
kubernetes_availability_zones = ["ap-south-1a"]
```

**Purpose:** AZs where Kubernetes nodes will be deployed
**Type:** list(string)
**Default:** ["ap-south-1a"]
**Value Examples:**
- For high availability: `["ap-south-1a", "ap-south-1b"]`
- For cost optimization: `["ap-south-1a"]` (single AZ)
- Multi-region support: Change to different region

**AZ Considerations:**
- Single AZ: Lower costs, faster networking between nodes
- Multiple AZs: Higher availability, but increases data transfer costs
- Must be valid for the region (ap-south-1 has: a, b, c)

**Cost Impact:**
- Single AZ: No inter-AZ data transfer charges
- Multiple AZs: $0.01/GB for inter-AZ transfers (significant for etcd replication)

---

### Master Node Configuration

```hcl
kubernetes_master_instance_type = "t2.medium"
```

**Purpose:** EC2 instance type for Kubernetes master node
**Type:** string
**Default:** "t2.medium"

**Recommended Types:**
```
Development/Testing:
  - t2.medium    ($0.0464/hr ≈ $34/month) ✓ Recommended
  - t2.small     ($0.0232/hr ≈ $17/month)
  - t2.micro     ($0.0116/hr ≈ $8/month)  [Too small]

Production:
  - t2.large     ($0.0928/hr ≈ $68/month)
  - m5.large     ($0.096/hr ≈ $70/month)
  - m5.xlarge    ($0.192/hr ≈ $140/month)
```

**Instance Type Comparison:**

| Type | vCPU | RAM | Network | Cost/mo | Tier | Notes |
|------|------|-----|---------|---------|------|-------|
| t2.micro | 1 | 1GB | Low | $8 | Burstable | Too small for master |
| t2.small | 1 | 2GB | Low | $17 | Burstable | Minimum for dev |
| t2.medium | 2 | 4GB | Low | $34 | Burstable | ✓ Recommended |
| t2.large | 2 | 8GB | Moderate | $68 | Burstable | Better for many pods |
| t3.medium | 2 | 4GB | Low | $30 | Burstable | Lower cost alternative |
| m5.large | 2 | 8GB | Moderate | $70 | General | More consistent performance |

**Selection Criteria:**
- **t2.medium minimum:** etcd requires 2GB+ RAM
- **2x vCPU minimum:** Controller manager and scheduler need processing power
- **t-series adequate:** Burst capacity handles API server spikes
- **Avoid t2.micro/small:** Will cause API server timeouts

**Cost Optimization:**
- t2.medium is sweet spot for dev
- t3.medium saves ~$4/month with same specs
- Burstable credits reset daily (good for dev)

---

### Worker Node Configuration

```hcl
kubernetes_worker_instance_type = "t3.small"
```

**Purpose:** EC2 instance type for Kubernetes worker node
**Type:** string
**Default:** "t3.small"

**Recommended Types:**
```
Development/Testing:
  - t3.small     ($0.0208/hr ≈ $15/month)  ✓ Recommended
  - t3.micro     ($0.0104/hr ≈ $8/month)   [Too small]
  - t2.small     ($0.0232/hr ≈ $17/month)
  - t2.micro     ($0.0116/hr ≈ $8/month)   [Too small]

Production:
  - t3.medium    ($0.0416/hr ≈ $30/month)
  - t3.large     ($0.0832/hr ≈ $61/month)
  - m5.large     ($0.096/hr ≈ $70/month)
  - c5.large     ($0.085/hr ≈ $62/month)
```

**Instance Type Comparison:**

| Type | vCPU | RAM | Cost/mo | T3 Speed | Notes |
|------|------|-----|---------|----------|-------|
| t3.micro | 1 | 1GB | $8 | Up to 3x | Docker + kubelet may struggle |
| t3.small | 2 | 2GB | $15 | Up to 3x | ✓ Recommended for dev |
| t3.medium | 2 | 4GB | $30 | Up to 3x | Better when running apps |
| t3.large | 2 | 8GB | $61 | Up to 3x | High-workload deployments |
| m5.large | 2 | 8GB | $70 | Baseline | Consistent performance |

**Selection Criteria:**
- **t3 advantages:** Lower cost than t2, better burstable performance
- **2GB RAM minimum:** Docker daemon + kubelet + system pods
- **2 vCPU minimum:** Application scheduling and network handling
- **Avoid t3.micro:** Only 1GB RAM insufficient for realistic workloads

**Cost Optimization:**
- t3.small optimized for costs (~$15/month vs t2.small $17/month)
- Can use multiple t3.small workers
- Consider Spot instances for non-critical workloads (70% savings)

---

### Pod Network Configuration

```hcl
kubernetes_pod_network_cidr = "10.244.0.0/16"
```

**Purpose:** CIDR block for pod overlay network (CNI plugin)
**Type:** string
**Default:** "10.244.0.0/16"
**Constraints:** Must not overlap with VPC CIDR or service CIDR

**Network Architecture:**
```
VPC Network:           10.1.0.0/16      (host IPs)
  └─ Pod Network:      10.244.0.0/16    (container IPs)
       └─ Services:    10.96.0.0/12     (Kubernetes internal)
            └─ DNS:    10.96.0.10
```

**Flannel VXLAN Setup:**
```
Node 1 (Master):        Node 2 (Worker):
├─ flannel.1 ifce       ├─ flannel.1 ifce
├─ cni0: 10.244.x.0/24  ├─ cni0: 10.244.y.0/24
└─ Pods: 10.244.x.*/24  └─ Pods: 10.244.y.*/24
   (port 4789 UDP backend)
```

**Allocation Strategy:**
- Master: 10.244.0.0/24 (256 pod IPs)
- Worker 1: 10.244.1.0/24 (256 pod IPs)
- Worker 2: 10.244.2.0/24 (256 pod IPs)
- ... up to 10.244.255.0/24

**Default Limits:**
- Maximum pods per node (default): 110
- With /24 per node: 256 available - plenty of headroom

**Change Hints:**
Unless you have specific enterprise networking requirements, keep default:
```hcl
kubernetes_pod_network_cidr = "10.244.0.0/16"  # Standard Kubernetes default
```

---

## Module Variables Reference

Location: `infrastructure/aws/modules/kubernetes/variables.tf`

### Required Variables (Must Provide)

#### project_name
```hcl
variable "project_name" {
  type = string
}
```
**Used for:** Resource naming and tagging
**Example:** "terraspan"
**Format:** Lowercase, alphanumeric, hyphens OK

#### environment
```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be: dev, staging, prod"
  }
}
```
**Used for:** Differentiating environments
**Values:** "dev", "staging", or "prod"
**Impact:** Affects naming, tagging, configurations

#### vpc_id
```hcl
variable "vpc_id" {
  type = string
}
```
**Used for:** Placing security group
**Example:** "vpc-0123456789abcdef0"
**Source in dev:** `module.kubernetes_networking[0].vpc_id`

#### vpc_cidr
```hcl
variable "vpc_cidr" {
  type = string
}
```
**Used for:** Security group CIDR rules (VPC-internal communication)
**Example:** "10.1.0.0/16"
**Source in dev:** `var.kubernetes_vpc_cidr`

#### public_subnet_id
```hcl
variable "public_subnet_id" {
  type = string
}
```
**Used for:** Node placement
**Example:** "subnet-0123456789abcdef0"
**Source in dev:** `module.kubernetes_networking[0].public_subnet_ids[0]`

#### key_name
```hcl
variable "key_name" {
  type = string
}
```
**Used for:** EC2 SSH key pair
**Example:** "kubernetes-key-test"
**Must exist:** In AWS account for target region

---

### Optional Variables (Have Defaults)

#### master_instance_type
```hcl
variable "master_instance_type" {
  type    = string
  default = "t2.medium"
}
```

#### worker_instance_type
```hcl
variable "worker_instance_type" {
  type    = string
  default = "t3.small"
}
```

#### master_volume_size
```hcl
variable "master_volume_size" {
  type    = number
  default = 30  # GB
  validation {
    condition     = var.master_volume_size >= 20
    error_message = "Minimum 20GB required"
  }
}
```

**Volume Size Considerations:**
- 20GB minimum for etcd + system components
- 30GB default provides buffer (recommended)
- Use 50GB+ for production with many pods
- Each extra 10GB adds ~$0.10/month (gp3)

#### worker_volume_size
```hcl
variable "worker_volume_size" {
  type    = number
  default = 20  # GB
  validation {
    condition     = var.worker_volume_size >= 20
    error_message = "Minimum 20GB required"
  }
}
```

**Volume Size Considerations:**
- 20GB minimum for Docker + pods
- Increase for application persistent data
- Or use separate EBS volumes or EFS

---

## Cost Optimization Scenarios

### Scenario 1: Minimal Dev Setup (Lowest Cost)

```hcl
enable_kubernetes = true
kubernetes_master_instance_type = "t2.small"      # -$17
kubernetes_worker_instance_type = "t3.micro"      # -$7
master_volume_size = 20
worker_volume_size = 20

# Monthly cost: ~$33 (baseline $53)
# Trade-off: t2.small may be tight for master
```

### Scenario 2: Balanced Dev (Recommended ✓)

```hcl
enable_kubernetes = true
kubernetes_master_instance_type = "t2.medium"     # $34
kubernetes_worker_instance_type = "t3.small"      # $15
master_volume_size = 30
worker_volume_size = 20

# Monthly cost: ~$53 (current setup)
# Sweet spot for development
```

### Scenario 3: Production Baseline

```hcl
enable_kubernetes = true
kubernetes_master_instance_type = "t3.medium"     # $30
kubernetes_worker_instance_type = "t3.medium"     # $30
master_volume_size = 50
worker_volume_size = 50

# Monthly cost: ~$65
# Suitable for production workloads
```

### Scenario 4: High Availability with Spot Workers

```hcl
enable_kubernetes = true
kubernetes_master_instance_type = "t3.medium"     # $30
kubernetes_worker_instance_type = "t3.medium"     # ~$9 (Spot)
kubernetes_availability_zones = ["ap-south-1a", "ap-south-1b"]

# Monthly cost: ~$60 (with spot)
# Note: Requires manual Spot instance setup
```

---

## Complete Variable Dependency Chart

```
env variables                     module variables
───────────────────             ─────────────────

enable_kubernetes ─────┐
                      ├──→ module.kubernetes_networking.count
kubernetes_vpc_cidr ──┤    module.kubernetes.count
                      │
kubernetes_azs ───────┤
                      ├──→ module.kubernetes_networking (VPC, subnets)
project_name ─────────┤    
environment ──────────┤
region ───────────────┘
tags ─────┐
          ├──→ All modules (tagging, naming)
          │
project_name ─┐
environment ──┤
              ├──→ module.kubernetes (resources)
k8s_vnc_cidr ──┤    (security groups, instances)
k8s_subnet_id ─┤
key_name ──────┤
instance types ┤
pod_cidr ──────┘
```

---

## Validation Rules

### VPC CIDR
- Must be valid CIDR: ✓ `10.1.0.0/16`, ✗ `10.1.0.0`
- Cannot overlap with main VPC
- Suggested: Use different third octet (main is 10.0, k8s is 10.1)

### Pod Network CIDR
- Must be valid CIDR: ✓ `10.244.0.0/16`
- Must differ from VPC CIDR: ✓ Different ranges
- Must differ from Service CIDR: ✓ Standard is 10.96.0.0/12

### Instance Types
- Must be t-family or m-family for cost
- No c-family (compute optimized, expensive)
- No r-family (memory optimized, expensive)
- Valid examples: t2.micro, t2.small, t2.medium, t3.small, t3.medium

### Availability Zones
- Must exist in target region
- ap-south-1 has: a, b, c
- us-east-1 has: a, b, c, d, e, f

---

## Quick Update Guide

To modify the cluster after deployment:

### Update Instance Type
```bash
# Edit terraform.tfvars
kubernetes_master_instance_type = "t2.large"

# Apply changes
terraform apply

# Old instance terminates, new one created
# Note: Downtime occurs during replacement
```

### Update Volume Size
```bash
# Cannot be done with terraform apply (requires manual expansion)
# But you can SSH and resize:
# ssh ubuntu@master
# lsblk
# sudo growpart /dev/nvme0n1 1
# sudo resize2fs /dev/nvme0n1p1
```

### Enable/Disable Cluster
```bash
enable_kubernetes = false  # Destroys all k8s resources

terraform apply

enable_kubernetes = true   # Recreates cluster

terraform apply
```

### Change Region
```bash
region = "us-east-1"
kubernetes_availability_zones = ["us-east-1a"]

terraform apply
```

---

## Summary Table

| Variable | Type | Default | Purpose | Critical |
|----------|------|---------|---------|----------|
| enable_kubernetes | bool | true | Deploy cluster | No |
| kubernetes_vpc_cidr | string | 10.1.0.0/16 | Cluster network | Yes |
| kubernetes_availability_zones | list | ["ap-south-1a"] | Node locations | Yes |
| kubernetes_master_instance_type | string | t2.medium | Master CPU/RAM | Yes |
| kubernetes_worker_instance_type | string | t3.small | Worker CPU/RAM | Yes |
| kubernetes_pod_network_cidr | string | 10.244.0.0/16 | Pod network | No |
| master_volume_size | number | 30 | Storage | No |
| worker_volume_size | number | 20 | Storage | No |

---

**Last Updated:** 2026-03-31
**Status:** Complete Configuration Reference
