module "kubernetes" {
  source        = "../../modules/kubernetes"
  cloud_provider = "aws"  # or "gcp", "azure"
  cluster_name   = "dev-cluster"

  # AWS-specific variables
  aws_region        = "us-east-1"
  cluster_role_arn  = "arn:aws:iam::123456789012:role/EKSRole"
  subnet_ids        = ["subnet-abc123", "subnet-def456"]

  # GCP-specific variables (not needed if using AWS, but required by the module definition, so can set defaults)
  gcp_project         = ""
  gcp_region          = ""
  initial_node_count  = 0
  machine_type        = ""

  # Azure-specific variables (not needed if using AWS, but required by the module definition, so can set defaults)
  resource_group_name = ""
  azure_location      = ""
  dns_prefix          = ""
  node_count          = 0
  vm_size             = ""
}