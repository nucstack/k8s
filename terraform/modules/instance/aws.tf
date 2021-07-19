
locals {
  tailscale_relay = {
    instance_type = "t2.micro"
    count         = 1
  }
  k3s_masters = {
    instance_type = "t2.micro"
    min_size          = 3
    max_size          = 3
    desired_capacity  = 3
  }
  k3s_workers = {
    instance_type = "t2.micro"
    min_size          = 5
    max_size          = 5
    desired_capacity  = 5
  }
}

// lookup latest tailscale-relay role AMI image
// TODO: target specific version
data "aws_ami" "tailscale-relay" {
  most_recent = true
  filter {
    name   = "tag:role"
    values = ["tailscale-relay"]
  }
  owners = ["self"]
}

// lookup latest k3s role AMI image
// TODO: target specific version
data "aws_ami" "k3s" {
  most_recent = true
  filter {
    name   = "tag:role"
    values = ["k3s"]
  }
  owners = ["self"]
}

// Add authorized public ssh key to AWS from generated tls_private_key
resource "aws_key_pair" "ssh-key-pair" {
  key_name   = "${var.name}-${var.environment}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

// Add VPC with private/public subnets
// Add a NAT GW for the private subnet(s)
// Add an IGW for the public subnets(s)
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

// deploy our tailscale relay instance in private subnet
module "tailscale-relay" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"
  count                  = var.type == "aws" ? 1 : 0

  name                   = "tailscale-relay"
  instance_count         = local.tailscale_relay.count

  ami                    = data.aws_ami.tailscale-relay.id
  instance_type          = local.k3s_masters.instance_type
  user_data_base64       = base64encode(<<-EOT
    #!/bin/bash
    # allows for IP forwarding
    # installs tailscale and enables the interface with the provided auth key
    # advertises all private subnets as routes available over this interface

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
  min_size                  = local.k3s_masters.min_size
  max_size                  = local.k3s_masters.max_size
  desired_capacity          = local.k3s_masters.desired_capacity
  vpc_zone_identifier       = module.vpc.0.private_subnets

  use_lt          = true
  create_lt       = true

  image_id          = data.aws_ami.k3s.id
  instance_type     = local.k3s_masters.instance_type
  ebs_optimized     = false
  enable_monitoring = false
  key_name          = aws_key_pair.ssh-key-pair.key_name
  placement = {
    availability_zone = module.vpc.0.azs.0
  }
  tags_as_map = {
    Name        = "k3s-masters"
    Role        = "k3s"
    Terraform   = "true"
    Environment = var.environment
  }
}

// k3s-workers autoscaling group
module "k3s-workers" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"
  count   = var.type == "aws" ? 1 : 0

  name                      = var.name
  min_size                  = local.k3s_workers.min_size
  max_size                  = local.k3s_workers.max_size
  desired_capacity          = local.k3s_workers.desired_capacity
  vpc_zone_identifier       = module.vpc.0.private_subnets

  use_lt          = true
  create_lt       = true

  image_id          = data.aws_ami.k3s.id
  instance_type     = local.k3s_workers.instance_type
  ebs_optimized     = false
  enable_monitoring = false
  key_name          = aws_key_pair.ssh-key-pair.key_name
  placement = {
    availability_zone = module.vpc.0.azs.0
  }
  tags_as_map = {
    Name        = "k3s-workers"
    Role        = "k3s"
    Terraform   = "true"
    Environment = var.environment
  }
}