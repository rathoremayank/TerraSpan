# Google Cloud Platform Infrastructure Module

This directory contains all GCP-specific infrastructure code for TerraSpan, organized into reusable modules and environment-specific configurations.

## Directory Structure

```
gcp/
├── modules/                   # Reusable GCP modules
│   ├── networking/           # VPCs, subnets, firewall rules, load balancers
│   ├── compute/              # Compute Engine, GKE, Cloud Run, App Engine
│   ├── storage/              # Cloud Storage, Persistent Disks, Firestore
│   ├── iam/                  # Service accounts, custom roles, policies
│   └── monitoring/           # Cloud Monitoring, Cloud Logging, Trace
└── environments/             # Environment-specific deployments
    ├── dev/                  # Development environment
    ├── staging/              # Staging environment
    └── prod/                 # Production environment
```

## GCP Modules

### 1. Networking Module (`networking/`)

Creates and manages GCP networking infrastructure.

**Outputs**: VPC ID, subnet IDs, firewall rule IDs, load balancer IPs

**Variables**:
- `network_name`: VPC network name
- `subnet_cidrs`: Map of subnet names to CIDR ranges
- `region`: GCP region
- `environment`: Environment name (dev/staging/prod)

**Example**:
```hcl
module "networking" {
  source = "../modules/networking"
  
  network_name = "terraspan-dev-vpc"
  region       = "us-central1"
  environment  = "dev"
  
  subnet_cidrs = {
    public  = "10.0.1.0/24"
    private = "10.0.2.0/24"
  }
  
  labels = merge(
    local.common_labels,
    { environment = "dev" }
  )
}
```

### 2. Compute Module (`compute/`)

Manages Compute Engine instances, GKE clusters, Cloud Run services, and instance groups.

**Outputs**: Instance names, cluster endpoints, service URLs

**Variables**:
- `machine_type`: Compute Engine machine type (e.g., "n1-standard-2")
- `instance_count`: Number of instances
- `disk_size_gb`: Boot disk size
- `enable_gke`: Enable GKE cluster creation

**Example**:
```hcl
module "compute" {
  source = "../modules/compute"
  
  machine_type    = "n1-standard-2"
  instance_count  = 2
  disk_size_gb    = 50
  enable_gke      = false
  
  labels = local.common_labels
}
```

### 3. Storage Module (`storage/`)

Creates Cloud Storage buckets, persistent disks, and Firestore databases.

**Outputs**: Bucket names, bucket URIs, disk IDs

**Variables**:
- `bucket_name`: Cloud Storage bucket name
- `storage_class`: Storage class (STANDARD, NEARLINE, COLDLINE)
- `versioning_enabled`: Enable bucket versioning
- `lifecycle_rules`: Object lifecycle management rules

**Example**:
```hcl
module "storage" {
  source = "../modules/storage"
  
  bucket_name         = "terraspan-dev-bucket"
  storage_class       = "STANDARD"
  versioning_enabled  = true
  
  lifecycle_rules = [
    {
      action          = "Delete"
      age_days        = 90
      num_newer_vers  = 5
    }
  ]
  
  labels = local.common_labels
}
```

### 4. IAM Module (`iam/`)

Manages service accounts, custom roles, and IAM bindings.

**Outputs**: Service account emails, role IDs, policy data

**Variables**:
- `service_account_name`: Service account name
- `display_name`: Service account display name
- `roles`: List of IAM roles to assign
- `custom_roles`: Custom role definitions

**Example**:
```hcl
module "iam" {
  source = "../modules/iam"
  
  service_account_name = "terraspan-dev-sa"
  display_name        = "TerraSpan Dev Service Account"
  
  roles = [
    "roles/compute.instanceAdmin.v1",
    "roles/storage.objectAdmin",
    "roles/logging.admin"
  ]
  
  labels = local.common_labels
}
```

### 5. Monitoring Module (`monitoring/`)

Sets up Cloud Logging, Cloud Monitoring, and alerting policies.

**Outputs**: Log sink names, alert policy IDs, dashboard URLs

**Variables**:
- `log_sink_name`: Cloud Logging sink name
- `notification_channels`: Notification channel IDs
- `log_retention_days`: Log retention in days
- `enable_profiler`: Enable Cloud Profiler

**Example**:
```hcl
module "monitoring" {
  source = "../modules/monitoring"
  
  log_sink_name       = "terraspan-dev-sink"
  log_retention_days  = 30
  enable_profiler     = true
  
  notification_channels = [
    google_monitoring_notification_channel.email.id
  ]
  
  labels = local.common_labels
}
```

## GCP Environments

### Development Environment (`environments/dev/`)

- **Purpose**: Experimental deployments, feature testing
- **Project**: Dedicated development project
- **Billing**: Development billing account
- **Quotas**: Standard quotas, cost-optimized
- **Backup**: Daily snapshots, 7-day retention

### Staging Environment (`environments/staging/`)

- **Purpose**: Pre-production validation
- **Project**: Separate staging project
- **Replication**: Regional replication
- **Backup**: Daily backups, 14-day retention
- **Compliance**: Pre-compliance validation

### Production Environment (`environments/prod/`)

- **Purpose**: Live production workloads
- **Project**: Dedicated production project
- **Replication**: Multi-region replication
- **Backup**: Continuous backup, 30-day retention
- **Compliance**: Full compliance validation
- **Monitoring**: Enhanced monitoring and SLO tracking
- **Approval**: Requires manual approval for apply

## Common Variables

All GCP modules use these common variables:

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `project_id` | string | Yes | GCP project ID |
| `environment` | string | Yes | Environment (dev/staging/prod) |
| `region` | string | Yes | GCP region |
| `labels` | map(string) | No | Common labels for all resources |

## GCP Best Practices Implemented

✅ **VPC Design**: Custom VPC with public/private subnets, Cloud NAT
✅ **Firewall Rules**: Principle of least privilege, tag-based rules
✅ **Service Accounts**: Workload identity, least-privilege permissions
✅ **IAM**: Predefined and custom roles, organization policies
✅ **Storage**: Object versioning, lifecycle policies, encryption
✅ **Monitoring**: Cloud Monitoring, Cloud Logging, uptime checks
✅ **Backup**: Cloud Backup integration, snapshots, replication
✅ **Compliance**: Cloud Audit Logs, VPC Service Controls

## Deployment

### Initialize GCP Environment

```bash
cd environments/dev

# Authenticate with Google Cloud
gcloud auth login

# Set project
gcloud config set project <PROJECT_ID>

# Initialize Terraform
terraform init
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

- **Backend**: Google Cloud Storage
- **Encryption**: Cloud KMS encryption
- **Versioning**: GCS object versioning enabled
- **Access**: IAM service account authentication

See [Remote State Configuration](../remote-state/README.md) for setup details.

## Troubleshooting

### Common Issues

**Authentication Error**
```bash
# Check current gcloud configuration
gcloud config list

# Re-authenticate
gcloud auth login

# Set correct project
gcloud config set project <PROJECT_ID>
```

**API Not Enabled**
```bash
# List enabled APIs
gcloud services list --enabled

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable storage-api.googleapis.com
```

**Quota Exceeded**
```bash
# Check quota usage
gcloud compute project-info describe --project=<PROJECT_ID>

# Request quota increase via GCP Console
```

## Related Documentation

- [Google Cloud Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- [Google Cloud Architecture Framework](https://cloud.google.com/architecture)
- [TerraSpan Main README](../../README.md)
- [Deployment Guide](../../docs/deployment.md)

## Support

For GCP-specific issues, check:
- Cloud Audit Logs for API calls
- Cloud Logging for application diagnostics
- Cloud Trace for performance tracking
- GCP Support: [Google Cloud Support](https://cloud.google.com/support)
