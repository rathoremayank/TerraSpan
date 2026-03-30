# AWS Development Environment - Main Configuration

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment after remote state bucket is created
  backend "s3" {
    bucket  = "terraspan-terraform-state-706073863179"
    key     = "aws/dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = merge(
      local.common_tags,
      {
        Environment = var.environment
        ManagedBy   = "Terraform"
      }
    )
  }
}

# Local values
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    CreatedAt   = "2026-03-29"
    ManagedBy   = "Terraform"
  }
}

# Networking module
module "networking" {
  source = "../../modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  region            = var.region
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones

  tags = local.common_tags
}

# Compute module for EC2 instances
module "compute" {
  source = "../../modules/compute"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnet_ids[0]
  instance_type    = var.instance_type
  key_name         = var.key_name

  tags = local.common_tags

  depends_on = [module.networking]
}

# Additional modules can be added here
# module "storage" { ... }
# module "iam" { ... }
# module "monitoring" { ... }
