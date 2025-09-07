locals {
  provider = var.cloud_provider
}

module "aws" {
  source       = "./aws"
  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  cluster_role_arn = var.cluster_role_arn
  subnet_ids   = var.subnet_ids
  count        = local.provider == "aws" ? 1 : 0
}

module "gcp" {
  source           = "./gcp"
  cluster_name     = var.cluster_name
  gcp_project      = var.gcp_project
  gcp_region       = var.gcp_region
  initial_node_count = var.initial_node_count
  machine_type     = var.machine_type
  count            = local.provider == "gcp" ? 1 : 0
}

module "azure" {
  source              = "./azure"
  cluster_name        = var.cluster_name
  resource_group_name = var.resource_group_name
  azure_location      = var.azure_location
  dns_prefix          = var.dns_prefix
  node_count          = var.node_count
  vm_size             = var.vm_size
  count               = local.provider == "azure" ? 1 : 0
}