variable "environment" {
  description = "vm environment."
  type        = string
  default     = "staging"
}

variable "type" {
  description = "instance types (virtual or physical)."
  type        = string
}

variable "instances" {
  description = "vm instances."
  type        = list(string)
  default     = []
}

variable "username" {
  description = "user to add during cloudinit."
  type        = string
  default     = ""
  sensitive   = true
}

variable "password" {
  description = "user password to add during cloudinit."
  type        = string
  default     = ""
  sensitive   = true
}

variable "ssh_authorized_key" {
  description = "ssh_authorized_key to add during cloudinit."
  type        = string
  default     = ""
}
