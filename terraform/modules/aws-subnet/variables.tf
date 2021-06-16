variable "environment" {
  description = "The Deployment environment"
}

variable "vpc_id" {
  description = "The vpc id to associate with these subnets"
}

variable "public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
}

variable "availability_zones" {
  type        = list
  description = "The az that the resources will be launched"
}