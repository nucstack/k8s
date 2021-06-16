
variable "application_name" {
  description = "application_name"
  type        = string
}

variable "environment" {
  description = "environment"
  type        = string
}

variable "subnet_id" {
  description = "subnet id"
}

variable "image_name" {
  type        = string
  description = "image name"
}

variable "availability_zones" {
  type        = list
  description = "The az that the resources will be launched"
}

variable "instance_type" {
  type        = string
  description = "instance type"
  default     = "t2.micro"
}

variable "security_group_id" {
  type        = string
  description = "security group id"
}

variable "tags" {
  type        = map(string)
  description = "tags"
}

variable "bootstrap_vars" {
  type        = map(string)
  description = "bootstrap_vars"
}

variable "desired_capacity" {
  type        = number
  description = "desired_capacity"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "max_size"
  default     = 1
}

variable "min_size" {
  type        = number
  description = "min_size"
  default     = 1
}