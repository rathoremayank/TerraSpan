# AWS Production Environment - Variables

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "terraspan"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.2.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for HA"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
