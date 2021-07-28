variable "environment" {
  description = "environment e.g. staging"
  type        = string
}

variable "type" {
  description = "infrastructure type. e.g. physical/aws/gcp"
  type        = string
}

variable "services" {
  description = "services to provision"
  default     = null
  type        = map(object({
    name = string
  }))
}