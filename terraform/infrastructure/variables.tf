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
  default     = []  
  type        = list(object({
    name      = string
    subnet    = string
    type      = string
    size      = string
    count     = number
  }))
}

variable "env_vars" {
  description = "additional env vars to include"
  default     = {}
  sensitive   = true
  type        = map(string)
}
