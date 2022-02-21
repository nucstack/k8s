variable "environment" {
  description = "environment e.g. staging"
  type        = string
}

variable "masters" {
  description = "masters count"
  type        = string
  default     = 3
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
    start_ip  = number
  }))
}

variable "env_vars" {
  description = "additional env vars to include"
  default     = {}
  sensitive   = true
  type        = map(string)
}

variable "ssh_username" {
  description = "ssh username"
  type        = string
  sensitive   = true
}

variable "ssh_password" {
  description = "ssh password"
  type        = string
  default     = ""
  sensitive   = true
}
