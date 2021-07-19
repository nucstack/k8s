
// lookup tailscale-relay AMI image
data "aws_ami" "tailscale-relay" {
  most_recent = true
  filter {
    name   = "tag:role"
    values = ["tailscale-relay"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  owners = ["self"]
}

// lookup k3s AMI image
data "aws_ami" "k3s" {
  most_recent = true
  filter {
    name   = "tag:role"
    values = ["k3s"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  owners = ["self"]
}

// Add ssh key 
resource "aws_key_pair" "ssh-key-pair" {
  key_name   = "${var.name}-${var.environment}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

// Add VPC
module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 3.0"
  count                  = var.type == "aws" ? 1 : 0

  name                   = "${var.environment}-vpc"
  cidr                   = "10.0.0.0/16"
  azs                    = ["us-east-2a"]
  private_subnets        = ["10.0.10.0/24"]
  public_subnets         = ["10.0.1.0/24"]
  create_igw             = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

// tailscale relay instance
module "tailscale-relay" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"
  count                  = var.type == "aws" ? 1 : 0

  name                   = "tailscale-relay"
  instance_count         = 1

  ami                    = data.aws_ami.tailscale-relay.id
  instance_type          = "t2.micro"
  user_data_base64       = base64encode(<<-EOT
    #!/bin/bash

    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
    echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p /etc/sysctl.conf

    sudo systemctl enable --now tailscaled
    sudo tailscale up --authkey "${var.tailscale_auth_key}" --advertise-routes=${join(",", module.vpc.0.private_subnets_cidr_blocks)}
  EOT
  )
  key_name               = aws_key_pair.ssh-key-pair.key_name
  monitoring             = false
  vpc_security_group_ids = [module.vpc.0.default_security_group_id]
  subnet_id              = module.vpc.0.private_subnets.0

  tags = {
    Name        = "tailscale-relay"
    Terraform   = "true"
    Environment = var.environment
  }
}

// k3s-masters autoscaling group
module "k3s-masters" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"
  count   = var.type == "aws" ? 1 : 0
  name                      = var.name
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1

  vpc_zone_identifier       = module.vpc.0.private_subnets

  use_lt          = true
  create_lt       = true

  image_id          = data.aws_ami.k3s.id
  instance_type     = "t2.micro"
  ebs_optimized     = false
  enable_monitoring = false
  user_data_base64  = base64encode(<<-EOT
    #!/bin/bash
    sudo k3s server
  EOT
  )
  key_name          = aws_key_pair.ssh-key-pair.key_name

  placement = {
    availability_zone = module.vpc.0.azs.0
  }
}