
locals {
  bootstrap_script = <<-EOT
    #!/bin/bash
    # register instance with tailscale
    sudo tailscale up --authkey "${var.tailscale_auth_key}"
    sleep 10
    TAILSCALE_IP=$(tailscale ip --4)
    # k3s server
    k3s server --advertise-ip $TAILSCALE_IP --flannel-iface tailscale0
  EOT
}

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
  enable_dns_support    = true
  #default_security_group_egress  = []
  #default_security_group_ingress = []
  #default_security_group_tags    = []

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

// packer AMI image
data "aws_ami" "image" {
  most_recent = true
  filter {
    name   = "name"
    values = ["k3s-*"]
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

// ssh key pair
resource "aws_key_pair" "ssh-key-pair" {
  key_name   = "k3s-master-${var.environment}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

// autoscaling group
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"
  count   = var.type == "aws" ? 1 : 0
  name                      = "k3s-master"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1

  vpc_zone_identifier       = module.vpc.0.private_subnets

  use_lt          = true
  create_lt       = true

  image_id          = data.aws_ami.image.id
  instance_type     = "t2.micro"
  ebs_optimized     = false
  enable_monitoring = false
  user_data_base64  = base64encode(local.bootstrap_script)
  key_name          = aws_key_pair.ssh-key-pair.key_name

  placement = {
    availability_zone = module.vpc.0.azs.0
  }
}