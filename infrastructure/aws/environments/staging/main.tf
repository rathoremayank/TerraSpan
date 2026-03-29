# AWS Staging Environment - Main Configuration

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment after remote state bucket is created
  # backend "s3" {
  #   bucket         = "terraspan-terraform-state"
  #   key            = "aws/staging/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraspan-locks"
  # }
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

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    CreatedAt   = "2026-03-29"
    ManagedBy   = "Terraform"
  }
}

# Module configuration for staging
module "networking" {
  source = "../modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  region            = var.region
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones

  tags = local.common_tags
}

# Add additional modules as needed
