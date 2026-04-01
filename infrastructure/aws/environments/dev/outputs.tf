# AWS Development Environment - Outputs

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "public_route_table_id" {
  description = "Public Route Table ID"
  value       = module.networking.public_route_table_id
}

output "private_route_table_id" {
  description = "Private Route Table ID"
  value       = module.networking.private_route_table_id
}

################################################################################
# Development EC2 Instances
################################################################################

# Instance 1 Outputs
output "dev_instance_1_id" {
  description = "Development EC2 instance 1 ID"
  value       = aws_instance.dev_instance_1.id
}

output "dev_instance_1_private_ip" {
  description = "Development EC2 instance 1 private IP"
  value       = aws_instance.dev_instance_1.private_ip
}

output "dev_instance_1_public_ip" {
  description = "Development EC2 instance 1 public IP"
  value       = aws_instance.dev_instance_1.public_ip
}

output "dev_instance_1_dns" {
  description = "Development EC2 instance 1 public DNS name"
  value       = aws_instance.dev_instance_1.public_dns
}

# Instance 2 Outputs
output "dev_instance_2_id" {
  description = "Development EC2 instance 2 ID"
  value       = aws_instance.dev_instance_2.id
}

output "dev_instance_2_private_ip" {
  description = "Development EC2 instance 2 private IP"
  value       = aws_instance.dev_instance_2.private_ip
}

output "dev_instance_2_public_ip" {
  description = "Development EC2 instance 2 public IP"
  value       = aws_instance.dev_instance_2.public_ip
}

output "dev_instance_2_dns" {
  description = "Development EC2 instance 2 public DNS name"
  value       = aws_instance.dev_instance_2.public_dns
}

# Security Group Output
output "dev_security_group_id" {
  description = "Security group ID for development EC2 instances"
  value       = aws_security_group.dev_instances.id
}

# Connection Info
output "connection_info" {
  description = "SSH connection information for development instances"
  value = {
    instance_1_ssh = "ssh -i /path/to/kubernetes-key-test.pem ubuntu@${aws_instance.dev_instance_1.public_ip}"
    instance_2_ssh = "ssh -i /path/to/kubernetes-key-test.pem ubuntu@${aws_instance.dev_instance_2.public_ip}"
  }
}

