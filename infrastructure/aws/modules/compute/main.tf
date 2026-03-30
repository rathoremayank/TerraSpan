# AWS Compute Module
# Reusable module for EC2 instances and related resources

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Security Group for Jenkins Server
resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg-${var.environment}"
  description = "Security group for Jenkins server"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins web interface
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-jenkins-sg-${var.environment}"
    }
  )
}

# EC2 Instance - Jenkins Server
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins.id]

  associate_public_ip_address = true

  # User data script to install Jenkins
  user_data = base64encode(templatefile("${path.module}/scripts/jenkins-init.sh", {
    jenkins_port = "8080"
  }))

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-jenkins-${var.environment}"
      Type = "Jenkins"
    }
  )

  depends_on = [aws_security_group.jenkins]
}

# Data source to get the latest Ubuntu 22.04 AMI
data "aws_ami" "amazon_linux_2" {
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
