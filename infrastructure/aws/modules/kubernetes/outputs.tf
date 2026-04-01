# AWS Kubernetes Module - Outputs

output "master_id" {
  description = "Master node instance ID"
  value       = aws_instance.master.id
}

output "master_private_ip" {
  description = "Master node private IP address"
  value       = aws_instance.master.private_ip
}

output "master_public_ip" {
  description = "Master node public IP address"
  value       = aws_instance.master.public_ip
}

output "master_eip" {
  description = "Master node Elastic IP address"
  value       = aws_eip.master.public_ip
}

output "worker_id" {
  description = "Worker node instance ID"
  value       = aws_instance.worker.id
}

output "worker_private_ip" {
  description = "Worker node private IP address"
  value       = aws_instance.worker.private_ip
}

output "worker_public_ip" {
  description = "Worker node public IP address"
  value       = aws_instance.worker.public_ip
}

output "security_group_id" {
  description = "Security group ID for Kubernetes cluster"
  value       = aws_security_group.kubernetes.id
}

output "kubernetes_cluster_name" {
  description = "Kubernetes cluster identifier"
  value       = "${var.project_name}-k8s-${var.environment}"
}

output "master_dns" {
  description = "Master node public DNS name"
  value       = aws_instance.master.public_dns
}

output "worker_dns" {
  description = "Worker node public DNS name"
  value       = aws_instance.worker.public_dns
}
