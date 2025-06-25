#!/bin/bash

# It installs all the necessary tools for the K8s assignment.

# Use -e to exit immediately if a command fails
set -e

echo "Starting prerequisite installation..."

# Update all yum packages
yum update -y

# --- Install Docker ---
echo "Installing Docker..."
yum install -y docker
systemctl start docker
systemctl enable docker
# Add the ec2-user to the docker group so not need to use sudo
usermod -aG docker ec2-user

# --- Install kubectl ---
echo "Installing kubectl..."
# Download a temporary location and then move it to a directory in the PATH
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.28.5/2024-01-04/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# --- Install kind ---
echo "Installing kind..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

echo "All prerequisites installed successfully!"