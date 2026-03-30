#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Java (required for Jenkins)
apt-get install -y openjdk-11-jdk-headless

# Add Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Update package list and install Jenkins
apt-get update
apt-get install -y jenkins

# Start Jenkins service
systemctl start jenkins
systemctl enable jenkins

# Create a marker file to indicate setup completion
touch /var/log/jenkins-setup-complete.log
echo "Jenkins setup completed at $(date)" >> /var/log/jenkins-setup-complete.log
