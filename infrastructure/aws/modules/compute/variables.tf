# AWS Compute Module - Variables

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  nullable    = false
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
  nullable    = false
}

variable "public_subnet_id" {
  description = "Public subnet ID for EC2 instances"
  type        = string
  nullable    = false
}

variable "instance_type" {
  description = "EC2 instance type (t2.micro for free tier)"
  type        = string
  default     = "t2.micro"
  
  validation {
    condition     = var.instance_type == "t2.micro"
    error_message = "Only t2.micro is allowed for free tier compatibility."
  }
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
