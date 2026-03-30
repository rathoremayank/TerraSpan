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

# Jenkins Server Outputs
output "jenkins_instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = module.compute.jenkins_instance_id
}

output "jenkins_public_ip" {
  description = "Jenkins server public IP - Access at http://<IP>:8080"
  value       = module.compute.jenkins_public_ip
}

output "jenkins_security_group_id" {
  description = "Jenkins security group ID"
  value       = module.compute.jenkins_security_group_id
}
