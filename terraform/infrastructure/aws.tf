
locals {  
  // aws-specific local vars
  aws_cidr            = "10.0.0.0/16"
  aws_azs             = ["us-east-2a"]
  aws_public_subnets  = ["10.0.1.0/24"]
  aws_private_subnets = [for s in var.services : s.subnet]

  // Used to pass useful information to our startup script render
  // TODO: don't always pass a list of all private subnets for the
  // tailscale relay.
  env_vars = merge(
    var.env_vars, 
    {"PRIVATE_SUBNETS" = join(",", local.aws_private_subnets)})
}

// spin up a VPC for our environment
module "vpc" {
  count                  = var.type == "aws" ? 1 : 0
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 3.0"

  name                   = var.environment
  cidr                   = local.aws_cidr
  azs                    = local.aws_azs
  public_subnets         = local.aws_public_subnets
  private_subnets        = local.aws_private_subnets
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
  count           = var.type == "aws" ? 1 : 0
  source          = "terraform-aws-modules/key-pair/aws"
  version         = "1.0.0"
  key_name        = var.environment
  public_key      = tls_private_key.ssh_key.public_key_openssh
  create_key_pair = true
  tags = {
    terraform   = "true"
    environment = var.environment
  }  
}

// lookup latest service role AMI image
// from our packer AMIs
data "aws_ami" "role_image" {
  for_each    = {for service in var.services: service.name => service if var.type == "aws"}
  most_recent = true
  filter {    
    name   = "tag:role"
    values = [each.value.name]
  }
  owners = ["self"]
}

data "aws_subnet" "private_subnet" {
  for_each = {for service in var.services: service.name => service if var.type == "aws"}
  cidr_block = each.value.subnet
}

data "template_file" "user_data" {
  for_each = {for service in var.services: service.name => service if var.type == "aws"}
  template = file("./startup_scripts/${each.value.name}.sh.tmpl")
  vars     = local.env_vars
}

// deploy our services of type 'ec2-instances'
module "ec2-instances" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  for_each               = {for service in var.services: service.name => service if service.type == "ec2-instance" && var.type == "aws"}
  version                = "~> 2.0"  

  name                   = each.value.name
  instance_count         = each.value.count
  instance_type          = each.value.size
  ami                    = data.aws_ami.role_image[each.value.name].id
  subnet_id              = data.aws_subnet.private_subnet[each.value.name].id
  key_name               = module.key_pair.0.key_pair_key_name  
  vpc_security_group_ids = [module.vpc.0.default_security_group_id]
  user_data_base64       = base64encode(data.template_file.user_data[each.value.name].rendered)
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
  for_each               = {for service in var.services:  service.name => service if service.type == "autoscaling" && var.type == "aws"}
  version                = "~> 4.0"
  name                   = each.value.name
  min_size               = each.value.count
  max_size               = each.value.count
  desired_capacity       = each.value.count
  instance_type          = each.value.size  
  image_id               = data.aws_ami.role_image[each.value.name].id
  vpc_zone_identifier    = [data.aws_subnet.private_subnet[each.value.name].id]  
  use_lt                 = true
  create_lt              = true
  ebs_optimized          = false
  enable_monitoring      = false
  key_name               = module.key_pair.0.key_pair_key_name
  user_data_base64       = base64encode(data.template_file.user_data[each.value.name].rendered)
  placement              = {
    availability_zone = local.aws_azs.0
  }  
  tags_as_map            = {
    Name        = each.value.name
    Environment = var.environment
    Terraform   = "true"
  }
}

data "aws_instances" "instances" {
  for_each      = {for service in var.services:  service.name => service if service.type == "autoscaling" && var.type == "aws"}
  instance_tags = {
    Name        = each.value.name
    Environment = var.environment
    Terraform   = "true"
  }
  instance_state_names = ["running"]
}