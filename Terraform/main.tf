#----------------------------------------------------------
# CLO 835 - Assignment2
#
# Build EC2 Instances
#
#----------------------------------------------------------

#  Define local tags
locals {
  default_tags = {
    "Owner"   = "MariaVSoto"
    "App"     = "K8s-Host"
    "Project" = "CLO835_A2"
  }
  name_prefix = "Assignment2"
}

#  Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Data block to retrieve the default VPC id
data "aws_vpc" "default" {
  default = true
}


# Reference subnet provisioned by default
resource "aws_instance" "K8s_VM" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.K8s_sg.id]
  associate_public_ip_address = true

  iam_instance_profile        = "LabInstanceProfile"

  user_data                   = file("install-tools.sh")


  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-VM"
    }
  )
}


# Security Group
resource "aws_security_group" "K8s_sg" {
  name        = "${local.name_prefix}-sg"
  description = "Allow SSH and K8s NodePort traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 30000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-sg"
    }
  )
}

# Elastic IP
resource "aws_eip" "static_eip" {
  instance = aws_instance.Web_VM.id
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-eip"
    }
  )
}

# --- ECR Repositories ---
# Amazon ECR Container Registry for the web application

resource "aws_ecr_repository" "webapp" {
  name = "my-webapp-image"

tags = local.default_tags
}

resource "aws_ecr_repository" "mysql" {
  name = "my-mysql-image"

tags = local.default_tags
}