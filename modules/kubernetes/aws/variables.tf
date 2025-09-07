variable "aws_region" {
  description = "The AWS region for the EKS cluster."
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "cluster_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS"
}