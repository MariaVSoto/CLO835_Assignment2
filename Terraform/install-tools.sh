#!/bin/bash
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
curl -LO /usr/local/bin/kubectl https://dl.k8s.io/release/v1.29.13/bin/linux/amd64/kubectl
chmod +x /usr/local/bin/kubectl

# --- Install kind ---
echo "Installing kind..."
curl -sLo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x /usr/local/bin/kind

# --- Configure ECR Credential Helper ---
echo "Installing and configuring ECR credential helper..."
yum install -y amazon-ecr-credential-helper

# Create the Docker config for the ec2-user to automatically use the helper
# This ensures that when you SSH in, your user is already configured.
mkdir -p /home/ec2-user/.docker
cat <<EOF > /home/ec2-user/.docker/config.json
{
    "credHelpers": {
        "public.ecr.aws": "ecr-login",
        "396561719560.dkr.ecr.us-east-1.amazonaws.com": "ecr-login"
    }
}
EOF
# Set the correct ownership for the config file
chown -R ec2-user:ec2-user /home/ec2-user/.docker

# --- Configure cgroups v2 for Kind ---
echo "Enabling cgroups v2..."
grubby --args="systemd.unified_cgroup_hierarchy=1" --update-kernel DEFAULT

echo "All prerequisites installed and system configured."
echo "Instance will now reboot to apply cgroups v2 setting."

# --- Reboot the instance ---
# The reboot is necessary for the cgroup setting to take effect.
# The User Data script will not run again after the reboot.
reboot