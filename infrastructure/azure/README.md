# Azure Infrastructure Module

This directory contains all Azure-specific infrastructure code for TerraSpan, organized into reusable modules and environment-specific configurations.

## Directory Structure

```
azure/
├── modules/                   # Reusable Azure modules
│   ├── networking/           # VNets, subnets, security groups, load balancers
│   ├── compute/              # VMs, AKS, App Service, scale sets
│   ├── storage/              # Storage accounts, managed disks, Cosmos DB
│   ├── iam/                  # Azure AD, Managed Identities, RBAC
│   └── monitoring/           # Azure Monitor, Application Insights, Log Analytics
└── environments/             # Environment-specific deployments
    ├── dev/                  # Development environment
    ├── staging/              # Staging environment
    └── prod/                 # Production environment
```

## Azure Modules

### 1. Networking Module (`networking/`)

Creates and manages Azure networking infrastructure.

**Outputs**: VNet ID, subnet IDs, NSG IDs, load balancer IPs

**Variables**:
- `vnet_address_space`: VNet address space (e.g., ["10.0.0.0/16"])
- `environment`: Environment name (dev/staging/prod)
- `location`: Azure region (e.g., "eastus")
- `resource_group_name`: Azure resource group name

**Example**:
```hcl
module "networking" {
  source = "../modules/networking"
  
  vnet_address_space    = ["10.0.0.0/16"]
  environment          = "dev"
  location            = "eastus"
  resource_group_name = "terraspan-dev-rg"
  
  tags = merge(
    local.common_tags,
    { Name = "terraspan-network-dev" }
  )
}
```

### 2. Compute Module (`compute/`)

Manages virtual machines, AKS clusters, App Services, and scale sets.

**Outputs**: VM IDs, cluster names, app service URLs

**Variables**:
- `vm_sku`: VM size (e.g., "Standard_B2s")
- `vm_count`: Number of VMs to create
- `enable_accelerated_networking`: Enable SR-IOV
- `os_type`: OS type (Windows, Linux)

**Example**:
```hcl
module "compute" {
  source = "../modules/compute"
  
  vm_sku                         = "Standard_B2s"
  vm_count                       = 2
  enable_accelerated_networking  = false
  os_type                        = "Linux"
  
  tags = local.common_tags
}
```

### 3. Storage Module (`storage/`)

Creates storage accounts, managed disks, and database resources.

**Outputs**: Storage account URLs, disk IDs, database connection strings

**Variables**:
- `storage_account_name`: Storage account name
- `storage_account_tier`: Storage tier (Standard, Premium)
- `replication_type`: Replication type (LRS, GRS, RAGRS)
- `db_engine`: Database type (postgres, mysql, mariadb)

**Example**:
```hcl
module "storage" {
  source = "../modules/storage"
  
  storage_account_name = "terraspandevsa"
  storage_account_tier = "Standard"
  replication_type    = "GRS"
  db_engine          = "postgres"
  
  tags = local.common_tags
}
```

### 4. IAM Module (`iam/`)

Manages Azure AD integration, managed identities, and RBAC.

**Outputs**: Principal IDs, role assignment IDs

**Variables**:
- `create_managed_identity`: Create user-assigned managed identity
- `identity_name`: Managed identity name
- `role_assignments`: List of role assignments

**Example**:
```hcl
module "iam" {
  source = "../modules/iam"
  
  create_managed_identity = true
  identity_name          = "terraspan-dev-identity"
  
  role_assignments = [
    {
      scope              = azurerm_storage_account.main.id
      role_definition_name = "Storage Blob Data Contributor"
    }
  ]
  
  tags = local.common_tags
}
```

### 5. Monitoring Module (`monitoring/`)

Sets up Azure Monitor, Application Insights, Log Analytics, and alerting.

**Outputs**: Log Analytics workspace ID, Application Insights keys

**Variables**:
- `log_analytics_workspace_name`: LAW name
- `retention_days`: Log retention in days
- `enable_app_insights`: Enable Application Insights
- `alert_email`: Email for alert notifications

**Example**:
```hcl
module "monitoring" {
  source = "../modules/monitoring"
  
  log_analytics_workspace_name = "terraspan-dev-law"
  retention_days              = 30
  enable_app_insights        = true
  alert_email                = "ops@terraspan.dev"
  
  tags = local.common_tags
}
```

## Azure Environments

### Development Environment (`environments/dev/`)

- **Purpose**: Experimental deployments, feature testing
- **Resource Group**: Single, shared resource group
- **Redundancy**: Locally redundant storage
- **Backup**: Daily snapshots, 7-day retention

### Staging Environment (`environments/staging/`)

- **Purpose**: Pre-production validation
- **Resource Group**: Separate staging resource group
- **Redundancy**: Zone-redundant where applicable
- **Backup**: Daily backups, 14-day retention

### Production Environment (`environments/prod/`)

- **Purpose**: Live production workloads
- **Resource Group**: Dedicated production resource group
- **Redundancy**: Geo-redundant storage, multi-region capability
- **Backup**: Continuous backup, 30-day retention
- **Compliance**: Full compliance with Azure Policy
- **Monitoring**: Enhanced metrics and alerting

## Common Variables

All Azure modules use these common variables:

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `project_name` | string | Yes | Project identifier |
| `environment` | string | Yes | Environment (dev/staging/prod) |
| `location` | string | Yes | Azure region |
| `resource_group_name` | string | Yes | Azure resource group |
| `tags` | map(string) | No | Common tags for all resources |

## Azure Best Practices Implemented

✅ **VNet Design**: Public/private subnet separation, Azure Firewall integration
✅ **NSG Rules**: Principle of least privilege, application-layer filtering
✅ **Managed Identities**: Service principal elimination, enhanced security
✅ **RBAC**: Role-based access control, custom roles where needed
✅ **Storage**: Encryption at rest, firewall rules, private endpoints
✅ **Monitoring**: Azure Monitor, Application Insights, Log Analytics integration
✅ **Backup**: Azure Backup integration, retention policies
✅ **Compliance**: Azure Policy enforcement, regulatory compliance templates

## Deployment

### Initialize Azure Environment

```bash
cd environments/dev

# Login to Azure
az login

# Set subscription
az account set --subscription <SUBSCRIPTION_ID>

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

- **Backend**: Azure Storage Account
- **Encryption**: Storage encryption at rest
- **Container**: Dedicated container for state
- **Access**: Managed identity or storage key authentication

See [Remote State Configuration](../remote-state/README.md) for setup details.

## Troubleshooting

### Common Issues

**Authentication Error**
```bash
# Check current Azure context
az account show

# Re-authenticate
az login

# Select correct subscription
az account set --subscription <SUBSCRIPTION_ID>
```

**Resource Group Not Found**
```bash
# List available resource groups
az group list

# Create resource group if needed
az group create --name terraspan-dev-rg --location eastus
```

**Quota Exceeded**
```bash
# Check quota usage
az vm list-usage --location eastus

# Request quota increase via Azure Portal
```

## Related Documentation

- [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/)
- [TerraSpan Main README](../../README.md)
- [Deployment Guide](../../docs/deployment.md)

## Support

For Azure-specific issues, check:
- Azure Activity Log for API calls
- Azure Monitor Logs for application diagnostics
- Network Watcher for network diagnostics
- Azure Support: [Azure Help + Support](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade)
