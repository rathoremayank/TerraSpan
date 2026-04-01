# AWS Kubernetes Module - Variables

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
  description = "VPC ID for the Kubernetes cluster"
  type        = string
  nullable    = false
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group rules"
  type        = string
  nullable    = false

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "public_subnet_id" {
  description = "Public subnet ID for Kubernetes nodes"
  type        = string
  nullable    = false
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  nullable    = false
}

variable "master_instance_type" {
  description = "Instance type for Kubernetes master node"
  type        = string
  default     = "t2.medium"
}

variable "worker_instance_type" {
  description = "Instance type for Kubernetes worker node"
  type        = string
  default     = "t3.small"
}

variable "master_volume_size" {
  description = "EBS volume size for master node (GB)"
  type        = number
  default     = 30

  validation {
    condition     = var.master_volume_size >= 20
    error_message = "Master volume size must be at least 20 GB."
  }
}

variable "worker_volume_size" {
  description = "EBS volume size for worker node (GB)"
  type        = number
  default     = 20

  validation {
    condition     = var.worker_volume_size >= 20
    error_message = "Worker volume size must be at least 20 GB."
  }
}

variable "pod_network_cidr" {
  description = "CIDR block for pod network (used by CNI)"
  type        = string
  default     = "10.244.0.0/16"

  validation {
    condition     = can(cidrhost(var.pod_network_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
