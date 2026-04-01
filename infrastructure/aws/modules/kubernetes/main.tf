# AWS Kubernetes Module
# Reusable module for Kubernetes cluster setup with master and worker nodes

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source to get the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Security Group for Kubernetes Cluster
resource "aws_security_group" "kubernetes" {
  name        = "${var.project_name}-k8s-sg-${var.environment}"
  description = "Security group for Kubernetes cluster"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-k8s-sg-${var.environment}"
    }
  )
}

# Ingress rule for SSH (port 22)
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.kubernetes.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
  description = "SSH access"

  tags = {
    Name = "allow-ssh"
  }
}

# Ingress rule for Kubernetes API (port 6443)
resource "aws_vpc_security_group_ingress_rule" "k8s_api" {
  security_group_id = aws_security_group.kubernetes.id

  from_port   = 6443
  to_port     = 6443
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr
  description = "Kubernetes API server"

  tags = {
    Name = "allow-k8s-api"
  }
}

# Ingress rule for kubelet API (port 10250)
resource "aws_vpc_security_group_ingress_rule" "kubelet_api" {
  security_group_id = aws_security_group.kubernetes.id

  from_port   = 10250
  to_port     = 10250
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr
  description = "Kubelet API"

  tags = {
    Name = "allow-kubelet-api"
  }
}

# Ingress rule for etcd (port 2379-2380)
resource "aws_vpc_security_group_ingress_rule" "etcd" {
  security_group_id = aws_security_group.kubernetes.id

  from_port   = 2379
  to_port     = 2380
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr
  description = "etcd communication"

  tags = {
    Name = "allow-etcd"
  }
}

# Ingress rule for pod networking (CNI plugins typically use 4789 for Flannel VXLAN)
resource "aws_vpc_security_group_ingress_rule" "cni" {
  security_group_id = aws_security_group.kubernetes.id

  from_port   = 4789
  to_port     = 4789
  ip_protocol = "udp"
  cidr_ipv4   = var.vpc_cidr
  description = "Pod network communication (CNI)"

  tags = {
    Name = "allow-cni"
  }
}

# Ingress rule for NodePort services (30000-32767)
resource "aws_vpc_security_group_ingress_rule" "nodeport" {
  security_group_id = aws_security_group.kubernetes.id

  from_port   = 30000
  to_port     = 32767
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
  description = "NodePort services"

  tags = {
    Name = "allow-nodeport"
  }
}

# Ingress rule for inter-node communication
resource "aws_vpc_security_group_ingress_rule" "inter_node" {
  security_group_id = aws_security_group.kubernetes.id

  from_port   = 0
  to_port     = 65535
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr
  description = "Inter-node communication"

  tags = {
    Name = "allow-inter-node"
  }
}

# Egress rule - Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.kubernetes.id

  from_port   = -1
  to_port     = -1
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
  description = "Allow all outbound traffic"

  tags = {
    Name = "allow-all-outbound"
  }
}

# Init script for master node
locals {
  master_init_script = base64encode(templatefile("${path.module}/scripts/master-init.sh", {
    pod_network_cidr = var.pod_network_cidr
  }))

  worker_init_script = base64encode(templatefile("${path.module}/scripts/worker-init.sh", {}))
}

# Master Node (Control Plane)
resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.master_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.kubernetes.id]

  associate_public_ip_address = true

  user_data = local.master_init_script

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.master_volume_size
    delete_on_termination = true
  }

  monitoring = false  # Disable detailed monitoring for cost optimization

  tags = merge(
    var.tags,
    {
      Name       = "${var.project_name}-k8s-master-${var.environment}"
      Type       = "Kubernetes-Master"
      NodeRole   = "control-plane"
    }
  )

  depends_on = [aws_security_group.kubernetes]
}

# Worker Node
resource "aws_instance" "worker" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.worker_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.kubernetes.id]

  associate_public_ip_address = true

  user_data = local.worker_init_script

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.worker_volume_size
    delete_on_termination = true
  }

  monitoring = false  # Disable detailed monitoring for cost optimization

  tags = merge(
    var.tags,
    {
      Name       = "${var.project_name}-k8s-worker-${var.environment}"
      Type       = "Kubernetes-Worker"
      NodeRole   = "worker"
    }
  )

  depends_on = [aws_security_group.kubernetes]
}

# Elastic IP for Master Node (optional, for stable public IP)
resource "aws_eip" "master" {
  instance = aws_instance.master.id
  domain   = "vpc"

  depends_on = [aws_instance.master]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-k8s-master-eip-${var.environment}"
    }
  )
}
