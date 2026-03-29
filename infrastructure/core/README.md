# Infrastructure Core Module

This directory contains shared, global configurations and variables used across all cloud providers in TerraSpan.

## Purpose

The core module provides:

1. **Common Variables**: Project name, environment, tagging standards
2. **Shared Outputs**: Centralized output definitions
3. **Global Configuration**: Naming conventions, policies
4. **Local Values**: Computed values used across modules

## Structure

```
core/
├── main.tf              # Global resources and locals
├── variables.tf         # Common variable definitions
├── outputs.tf          # Shared output definitions
└── terraform.tfvars    # Global variable values
```

## Common Variables

### Project Configuration

```hcl
variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "terraspan"
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod"
  }
}
```

### Tagging Standards

All resources should include tags following:

```hcl
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    CreatedAt   = "2026-03-29"
    ManagedBy   = "Terraform"
    CostCenter  = var.cost_center
  }
}
```

## Usage Example

### Referencing Core Values

```hcl
# In any module or environment
locals {
  common_tags = merge(
    var.common_tags,
    {
      Component = "networking"
    }
  )
}

resource "aws_vpc" "main" {
  # ...
  tags = local.common_tags
}
```

## Naming Conventions

### Resource Naming Pattern

```
<cloud>_<resource_type>_<project>_<environment>_<component>

Examples:
- aws_vpc_terraspan_dev_main
- azure_resource_group_terraspan_prod_network
- gcp_network_terraspan_staging_primary
```

### Module Output Naming

```
<component>_<attribute>

Examples:
- vpc_id
- subnet_ids
- security_group_id
- storage_account_endpoint
```

## Shared Functions and Locals

### Environment-based Configuration

```hcl
locals {
  environment_config = {
    dev = {
      instance_count      = 1
      backup_retention    = 7
      enable_monitoring   = false
      cost_optimization   = true
    }
    staging = {
      instance_count      = 2
      backup_retention    = 14
      enable_monitoring   = true
      cost_optimization   = false
    }
    prod = {
      instance_count      = 3
      backup_retention    = 30
      enable_monitoring   = true
      cost_optimization   = false
    }
  }
  
  env_config = local.environment_config[var.environment]
}
```

### Multi-Region Support

```hcl
locals {
  region_config = {
    us-east-1 = {
      azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
    us-west-2 = {
      azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
    }
  }
}
```

## Best Practices

✅ Keep core module minimal and focused
✅ Define all common variables here
✅ Use consistent naming conventions
✅ Document all variables and outputs
✅ Update core when adding new providers
✅ Version core changes carefully
✅ Test changes across all providers

## Related Documentation

- [Architecture Guide](../../docs/architecture.md)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/recommended-practices/index.html)
- [Module Development](../../docs/modules/README.md)
