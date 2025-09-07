variable "gcp_project" {
  description = "The GCP project ID."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region for the cluster."
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
}

variable "initial_node_count" {
  description = "Initial number of nodes in the cluster."
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Machine type for the cluster nodes."
  type        = string
  default     = "e2-medium"
}