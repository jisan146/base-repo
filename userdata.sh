#!/bin/bash


echo "Starting User Data script execution..."

# 1. Install Java
echo "Installing Java Development Kit (JDK 11)..."
sudo yum update -y
sudo amazon-linux-extras install java-openjdk11 -y
echo "Java installation complete."

# 2. Install Jenkins
echo "Installing Jenkins..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y
echo "Jenkins installation complete."

# 3. Install Docker
echo "Installing Docker..."
sudo yum install docker -y
echo "Docker installation complete."

# 4. Start and enable Docker service
echo "Starting and enabling Docker service..."
sudo systemctl start docker
sudo systemctl enable docker
echo "Docker service configured."

# 5. Add jenkins user to the docker group
# This allows Jenkins to run Docker commands without sudo
echo "Adding jenkins user to the docker group..."
sudo usermod -a -G docker jenkins
echo "Jenkins user added to docker group."

# 6. Restart Docker and Jenkins services to apply changes
echo "Restarting Docker service..."
sudo systemctl restart docker
echo "Docker service restarted."

echo "Restarting Jenkins service..."
sudo systemctl restart jenkins
echo "Jenkins service restarted."

echo "User Data script execution finished. Jenkins should be accessible on port 8080."
echo "You can find the initial admin password at /var/lib/jenkins/secrets/initialAdminPassword"

