provider "aws" {
  region = var.aws_region
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}