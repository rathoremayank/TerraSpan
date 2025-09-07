provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.gcp_region

  initial_node_count = var.initial_node_count

  node_config {
    machine_type = var.machine_type
  }
}

output "endpoint" {
  value = google_container_cluster.this.endpoint
}