#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install container runtime (Docker)
apt-get install -y docker.io git curl

# Start Docker service
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install Minikube
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
chmod +x minikube-linux-amd64
mv minikube-linux-amd64 /usr/local/bin/minikube

# Install virtualization tools
apt-get install -y libvirt-daemon-system libvirt-clients qemu-system-x86 qemu-utils

# Start libvirtd
systemctl start libvirtd
systemctl enable libvirtd

# Add ubuntu user to libvirt group
usermod -aG libvirt ubuntu

# Create a marker file to indicate setup completion
touch /var/log/minikube-setup-complete.log
echo "Minikube setup completed at $(date)" >> /var/log/minikube-setup-complete.log
