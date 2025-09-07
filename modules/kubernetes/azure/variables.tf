variable "cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "azure_location" {
  description = "The Azure region where the cluster will be deployed."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the default node pool."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for the default node pool."
  type        = string
  default     = "Standard_DS2_v2"
}