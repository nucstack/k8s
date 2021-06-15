
variable "region" {
  description = "region"
  type        = string
  default     = "us-east-2"
}

variable "availability_zones" {
  description = "availability zones"
  type        = list
  default     = ["us-east-2a"] 
}

variable "vpc_cidr" {
  description = "vpc_cidr zones"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "public subnets"
  type        = list
  default     = ["10.0.1.0/24"] 
}

variable "private_subnets_cidr" {
  description = "private subnets"
  type        = list
  default     = ["10.0.10.0/24"]
}

// vpc, subnets, gws, routes
module "networking" {
  source = "../../modules/aws-networking"
  count                = var.type == "aws" ? 1 : 0
  region               = var.region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = var.availability_zones
}

// auto scaling instances
module "asg-instances" {
  source             = "../../modules/aws-asg"
  count              = var.type == "aws" ? length(tolist(element(module.networking.0.private_subnets_id, 0))) : 0
  application_name   = "k3s"
  environment        = var.environment
  subnet_id          = element(tolist(element(module.networking.0.private_subnets_id, 0)), count.index)
  image_name         = "k3s-*"
  availability_zones = var.availability_zones  
  security_group_id  = module.networking.0.default_sg_id
  tags               = var.tags
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
  bootstrap_vars     = {
    TAILSCALE_AUTH_KEY = var.tailscale_auth_key
  }
  depends_on = [
    module.networking
  ]
}