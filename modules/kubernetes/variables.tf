variable "cloud_provider" {
  type        = string
  description = "Cloud provider to use: aws, gcp, or azure."
}

variable "cluster_name" {
  type = string
}

# AWS variables
variable "aws_region" {}
variable "cluster_role_arn" {}
variable "subnet_ids" {
  type = list(string)
}

# GCP variables
variable "gcp_project" {}
variable "gcp_region" {}
variable "initial_node_count" {}
variable "machine_type" {}

# Azure variables
variable "resource_group_name" {}
variable "azure_location" {}
variable "dns_prefix" {}
variable "node_count" {}
variable "vm_size" {}