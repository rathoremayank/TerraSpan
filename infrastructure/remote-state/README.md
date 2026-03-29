# Remote State Management

This directory contains configurations and documentation for managing Terraform remote state across all cloud providers.

## Overview

Remote state management is critical for multi-cloud infrastructure provisioning. TerraSpan uses cloud-native backends to ensure:

- **Durability**: State files backed up and replicated
- **Security**: Encryption at rest and in transit
- **Concurrency**: State locking prevents concurrent modifications
- **Auditability**: All state operations logged
- **Accessibility**: Central state management across teams

## Backend Configurations

### AWS S3 Backend

**Location**: `aws/environments/*/backend.tf`

Stores state in Amazon S3 with DynamoDB-based state locking.

**Architecture**:
- S3 bucket for state file storage
- DynamoDB table for state locking
- KMS key for encryption
- CloudTrail for audit logging
- S3 versioning for recovery

**Setup**:

```bash
# Create S3 bucket
aws s3 mb s3://terraspan-terraform-state --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket terraspan-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraspan-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

**Configuration**:

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "terraspan-terraform-state"
    key            = "aws/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraspan-locks"
    kms_key_id     = "arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID"
  }
}
```

### Azure Storage Backend

**Location**: `azure/environments/*/backend.tf`

Stores state in Azure Storage Account with lease-based state locking.

**Architecture**:
- Storage Account for state blob
- Container for state objects
- Managed identity for authentication
- Storage encryption with CMK
- Activity logging for audit trail

**Setup**:

```bash
# Create resource group
az group create \
  --name terraspan-state-rg \
  --location eastus

# Create storage account
az storage account create \
  --name terraspanstate \
  --resource-group terraspan-state-rg \
  --location eastus \
  --sku Standard_ZRS \
  --encryption-services blob

# Create container
az storage container create \
  --name tfstate \
  --account-name terraspanstate
```

**Configuration**:

```hcl
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "terraspan-state-rg"
    storage_account_name = "terraspanstate"
    container_name       = "tfstate"
    key                  = "azure/dev/terraform.tfstate"
  }
}
```

### Google Cloud Storage Backend

**Location**: `gcp/environments/*/backend.tf`

Stores state in Google Cloud Storage with object locking.

**Architecture**:
- GCS bucket for state storage
- Service account for authentication
- Cloud KMS encryption key
- GCS object versioning
- Cloud Audit Logs for tracking

**Setup**:

```bash
# Create GCS bucket
gsutil mb -b on -l us-central1 gs://terraspan-terraform-state

# Enable versioning
gsutil versioning set on gs://terraspan-terraform-state

# Create service account
gcloud iam service-accounts create terraspan-tf-admin \
  --display-name="TerraSpan Terraform Admin"

# Grant permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:terraspan-tf-admin@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/storage.admin
```

**Configuration**:

```hcl
# backend.tf
terraform {
  backend "gcs" {
    bucket = "terraspan-terraform-state"
    prefix = "gcp/dev"
  }
}
```

## State File Organization

### Directory Structure

```
s3://terraspan-terraform-state/
├── aws/
│   ├── dev/terraform.tfstate
│   ├── staging/terraform.tfstate
│   └── prod/terraform.tfstate
├── azure/
│   ├── dev/terraform.tfstate
│   ├── staging/terraform.tfstate
│   └── prod/terraform.tfstate
└── gcp/
    ├── dev/terraform.tfstate
    ├── staging/terraform.tfstate
    └── prod/terraform.tfstate
```

### Naming Convention

- Provider: `aws`, `azure`, `gcp`
- Environment: `dev`, `staging`, `prod`
- Format: `{provider}/{environment}/terraform.tfstate`

## State Locking

### Purpose

State locking prevents concurrent modifications that could corrupt state:

- Terraform automatically acquires locks during apply
- Locks are released after apply completes
- Stale locks can be manually removed

### Lock Timeout Configuration

```hcl
terraform {
  backend "s3" {
    # ... other config ...
    skip_credentials_validation = false
    skip_metadata_api_check     = false
    
    # Lock timeout (if getting timeout errors)
    # skip_requesting_account_id  = false
  }
}
```

### Force Unlock (Emergency Only)

```bash
# List current locks
terraform state list

# Force unlock (use with extreme caution!)
terraform force-unlock <LOCK_ID>
```

## Backup and Recovery

### Automated Backups

**AWS**:
- S3 versioning enabled
- Cross-region replication configured
- Point-in-time recovery available

**Azure**:
- BLOB soft delete enabled
- Azure Backup integration
- Geo-redundant storage (GRS)

**GCP**:
- Object versioning enabled
- Cross-region replication
- GCS transfer service for backups

### Manual Backup

```bash
# AWS
aws s3 cp s3://terraspan-terraform-state/aws/dev/terraform.tfstate ./backup-$(date +%s).tfstate

# Azure
az storage blob download \
  --account-name terraspanstate \
  --container-name tfstate \
  --name azure/dev/terraform.tfstate \
  --file backup-$(date +%s).tfstate

# GCP
gsutil cp gs://terraspan-terraform-state/gcp/dev/terraform.tfstate backup-$(date +%s).tfstate
```

### Recovery Procedure

```bash
# 1. Identify backup to restore
ls -la backup-*.tfstate

# 2. Backup current state
terraform state pull > current-state.tfstate

# 3. Restore from backup
terraform state push backup-1234567890.tfstate

# 4. Verify state
terraform state list
```

## Access Control

### AWS S3 Backend Access

```hcl
# IAM policy for state access
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TerraformStateS3",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketVersioning"
      ],
      "Resource": "arn:aws:s3:::terraspan-terraform-state"
    },
    {
      "Sid": "TerraformStateS3Objects",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::terraspan-terraform-state/*"
    },
    {
      "Sid": "TerraformLocking",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:DescribeTable"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:ACCOUNT_ID:table/terraspan-locks"
    }
  ]
}
```

### Azure Storage Backend Access

```bash
# Role assignment using managed identity
az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee-object-id <OBJECT_ID> \
  --scope /subscriptions/SUBSCRIPTION_ID/resourceGroups/terraspan-state-rg/providers/Microsoft.Storage/storageAccounts/terraspanstate
```

### GCP Storage Backend Access

```bash
# Grant Cloud Storage Admin role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:SERVICE_ACCOUNT@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/storage.admin
```

## State Migration

### Migrating Between Backends

```bash
# 1. Update backend configuration in backend.tf

# 2. Initialize new backend
terraform init

# 3. Confirm migration
# Terraform will prompt to copy state

# 4. Verify state transferred
terraform state list
terraform show
```

### Backing Up Before Migration

```bash
# Create current backup
terraform state pull > pre-migration-backup-$(date +%s).tfstate

# Verify backup
terraform state -chdir=pre-migration-backup-$(date +%s).tfstate list
```

## Monitoring and Security

### State Access Monitoring

**AWS**:
```bash
# View state bucket access logs
aws s3api get-bucket-logging --bucket terraspan-terraform-state
```

**Azure**:
```bash
# Enable storage account logging
az storage logging update \
  --account-name terraspanstate \
  --services b \
  --log crud \
  --retention 30
```

**GCP**:
```bash
# Query audit logs
gcloud logging read "resource.type=gcs_bucket AND resource.labels.bucket_name=terraspan-terraform-state"
```

## Best Practices

✅ **Always use remote state** in production
✅ **Enable state locking** to prevent concurrent modifications
✅ **Encrypt state at rest** using cloud-native encryption
✅ **Implement access controls** using IAM
✅ **Monitor state access** through audit logs
✅ **Backup state regularly** and test recovery
✅ **Use separate state files** per environment
✅ **Version control state** for recovery capability
✅ **Rotate credentials** regularly
✅ **Document state procedures** for team members

## Troubleshooting

### Error: "Resource already managed by Terraform"

```bash
# View remote state
terraform state list

# Check resource is registered
terraform state show <resource>

# If conflict, refresh state
terraform refresh
```

### Error: "Error acquiring the state lock"

```bash
# Check lock status
aws dynamodb scan --table-name terraspan-locks

# Delete stale lock (use with caution)
aws dynamodb delete-item --table-name terraspan-locks --key '{"LockID":{"S":"aws/dev/terraform.tfstate"}}'
```

### State Corruption

```bash
# 1. Pull current state
terraform state pull > corrupted-state.tfstate

# 2. Restore from backup
terraform state push backup-TIMESTAMP.tfstate

# 3. Reapply if needed
terraform plan
terraform apply
```

## Related Documentation

- [Terraform Remote State Documentation](https://www.terraform.io/language/state/remote)
- [AWS S3 Backend](https://www.terraform.io/language/settings/backends/s3)
- [Azure Backend](https://www.terraform.io/language/settings/backends/azurerm)
- [GCS Backend](https://www.terraform.io/language/settings/backends/gcs)
- [TerraSpan Deployment Guide](../../docs/deployment.md)
