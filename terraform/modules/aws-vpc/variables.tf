variable "cidr_block" {
  type        = string
  description = "The CIDR block of the vpc"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "enable dns hostnames"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "enable dns support"
  default     = true
}

variable "environment" {
  description = "environment"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "tags"
  default     = {}
}