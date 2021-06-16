
variable "vpcs" {  
  default = {
    staging = {
      application_name     = "k3s"
      image_name           = "k3s=*"
      region               = ["us-east-2"]
      availability_zones   = ["us-east-2a"]
      cidr_block           = "10.0.0.0/16"
      public_subnets_cidr  = ["10.0.1.0/24"]
      private_subnets_cidr = ["10.0.10.0/24"]
      desired_capacity     = 1
      min_size             = 1
      max_size             = 1
    }
  }
}

// sets up vpc
module "vpc" {
  source = "../../modules/aws-vpc"
  count                   = var.type == "aws" ? 1 : 0
  cidr_block              = var.vpcs[var.environment].cidr_block
  environment             = var.environment
}

// sets up subnet(s)/igw/natgw/routes
module "subnet" {
  source = "../../modules/aws-subnet"
  count                   = var.type == "aws" ? 1 : 0
  environment             = var.environment
  availability_zones      = var.vpcs[var.environment].availability_zones
  public_subnets_cidr     = var.vpcs[var.environment].public_subnets_cidr
  private_subnets_cidr    = var.vpcs[var.environment].private_subnets_cidr
  vpc_id                  = module.vpc.0.vpc_id
}

// auto scaling instances
module "instances" {
  source             = "../../modules/aws-auto-scaling-group"
  count              = var.type == "aws" ? length(tolist(element(module.subnet.0.private_subnets_id, 0))) : 0
  application_name   = var.vpcs[var.environment].application_name
  environment        = var.environment
  subnet_id          = element(tolist(element(module.subnet.0.private_subnets_id, 0)), count.index)
  image_name         = var.vpcs[var.environment].image_name
  availability_zones = var.vpcs[var.environment].availability_zones
  security_group_id  = module.vpc.0.default_sg_id
  tags               = var.tags
  desired_capacity   = var.vpcs[var.environment].desired_capacity
  max_size           = var.vpcs[var.environment].max_size
  min_size           = var.vpcs[var.environment].min_size
  bootstrap_vars     = {
    TAILSCALE_AUTH_KEY = var.tailscale_auth_key
  }
  depends_on = [
    module.vpc,
    module.subnet
  ]
}