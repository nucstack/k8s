
locals {  
  // aws-specific local vars
  aws_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-2a"]
  public_subnets     = ["10.0.1.0/24"]
  
  private_subnets    = [for s in var.services : s.subnet]

  // TODO: make this a template
  startup_scripts = {
    tailscale-relay = base64encode(<<-EOT
      #!/bin/bash
      echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
      echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
      sudo sysctl -p /etc/sysctl.conf
      sudo systemctl enable --now tailscaled
      sudo tailscale up --authkey "xxxxxx" --advertise-routes=${join(",", local.private_subnets)}
    EOT
    )
    k3s = base64encode(<<-EOT
      #!/bin/bash
      echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
      echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
      sudo sysctl -p /etc/sysctl.conf
      sudo systemctl enable --now tailscaled
      sudo tailscale up --authkey "xxxxxx" --advertise-routes=${join(",", local.private_subnets)}
    EOT
    )
  }
}

// spin up a VPC for our environment
module "vpc" {
  count                  = var.type == "aws" ? 1 : 0
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 3.0"

  name                   = var.environment
  cidr                   = local.aws_cidr
  azs                    = local.availability_zones
  public_subnets         = local.public_subnets
  private_subnets        = local.private_subnets
  create_igw             = true  // create our IGW
  enable_nat_gateway     = true  // create our NAT-GW
  single_nat_gateway     = true  // shared NAT gateway private subnet(s)
  one_nat_gateway_per_az = false // shared NAT gateway for all AZs
  enable_dns_support     = true  // enable dns support within our subnets
  enable_dns_hostnames   = true  // enable dns hostnames within our subnets

  // some tags to associate with our resources
  tags = {
    terraform   = "true"
    environment = var.environment
  }
}

// Generate a new key pair for each service
module "key_pair" {
  for_each        = {for service in var.services:  service.name => service}
  source          = "terraform-aws-modules/key-pair/aws"
  version         = "1.0.0"
  key_name        = each.value.name
  create_key_pair = true
  tags = {
    Name        = each.value.name
    terraform   = "true"
    environment = var.environment
  }  
}

// lookup latest service role AMI image
// from our packer AMIs
data "aws_ami" "role_image" {
  for_each    = {for service in var.services:  service.name => service}
  most_recent = true
  filter {    
    name   = "tag:role"
    values = [each.value.name]
  }
  owners = ["self"]
}

// deploy our services of type 'ec2-instances'
module "ec2-instances" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  for_each               = {for service in var.services:  service.name => service if service.type == "ec2-instance"}
  version                = "~> 2.0"  

  name                   = each.value.name
  instance_count         = each.value.count
  instance_type          = each.value.size
  ami                    = data.aws_ami.role_image[each.value.name].id
  key_name               = module.key_pair[each.value.name].key_pair_key_name
  vpc_security_group_ids = [module.vpc.0.default_security_group_id]
  subnet_id              = each.value.subnet
  user_data_base64       = local.startup_scripts[each.value.name]
  monitoring             = false
  tags                   = {
    Name        = each.value.name
    Environment = var.environment
    Terraform   = "true"
  }
}

// deploy our services of type 'autoscaling'
module "autoscaling-instances" {
  source                 = "terraform-aws-modules/autoscaling/aws"
  for_each               = {for service in var.services:  service.name => service if service.type == "autoscaling"}
  version                = "~> 4.0"
  name                   = each.value.name
  min_size               = each.value.count
  max_size               = each.value.count
  desired_capacity       = each.value.count
  vpc_zone_identifier    = [each.value.subnet]
  image_id               = data.aws_ami.role_image[each.value.name].id
  instance_type          = each.value.size
  use_lt                 = true
  create_lt              = true
  ebs_optimized          = false
  enable_monitoring      = false
  key_name               = module.key_pair[each.value.name].key_pair_key_name
  user_data_base64       = local.startup_scripts[each.value.name]
  placement              = {
    availability_zone = local.availability_zones.0
  }  
  tags_as_map            = {
    Name        = each.value.name
    Environment = var.environment
    Terraform   = "true"
  }
}