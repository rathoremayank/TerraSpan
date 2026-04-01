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
    region  = "ap-south-1"
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
    CreatedAt   = "2026-04-01"
    ManagedBy   = "Terraform"
  }
}

# Networking module
module "networking" {
  source = "../../modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  tags = local.common_tags
}

# Data source to get the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Security group for development EC2 instances
resource "aws_security_group" "dev_instances" {
  name        = "${var.project_name}-dev-sg-${var.environment}"
  description = "Security group for development EC2 instances"
  vpc_id      = module.networking.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-dev-sg-${var.environment}"
    }
  )

  depends_on = [module.networking]
}

# EC2 Instance 1 (t2.micro)
resource "aws_instance" "dev_instance_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = module.networking.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.dev_instances.id]

  associate_public_ip_address = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-dev-instance-1-${var.environment}"
      Type = "Development"
    }
  )

  depends_on = [aws_security_group.dev_instances]
}

# EC2 Instance 2 (t2.micro)
resource "aws_instance" "dev_instance_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = module.networking.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.dev_instances.id]

  associate_public_ip_address = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-dev-instance-2-${var.environment}"
      Type = "Development"
    }
  )

  depends_on = [aws_security_group.dev_instances]
}

# Additional modules can be added here
# module "storage" { ... }
# module "iam" { ... }
# module "monitoring" { ... }
