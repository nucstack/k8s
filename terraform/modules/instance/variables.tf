variable "environment" {
  description = "vm environment."
  type        = string
  default     = "staging"
}

variable "type" {
  description = "instance types (virtual or physical)."
  type        = string
}

variable "name" {
  description = "vm name prefix."
  type        = string
}

variable "description" {
  description = "vm description."
  type        = string
  default     = ""
}

variable "instances" {
  description = "vm instances."
  type        = list(string)
  default     = []
}

variable "pool" {
  description = "vm pool."
  type        = string
  default     = ""
}

variable "os_type" {
  description = "os type."
  type        = string
  default     = "cloud-init"
}

variable "template" {
  description = "vm template to clone."
  type        = string
  default     = "debian10-cloudinit"
}

variable "onboot" {
  description = "start vm on boot."
  type        = bool
  default     = true
}

variable "full_clone" {
  description = "perform a full clone."
  type        = bool
  default     = true
}

variable "target_node" {
  description = "target proxmox node in cluster."
  type        = string
  default     = "proxmox-01"
}

variable "network" {
  description = "network configuration."
  type        = list
  default     = [{
    model  = "virtio"
    bridge = "vmbr0"
    tag    = 80
  }]
}

variable "disk" {
  description = "boot disk size."
  type        = list
  default     = [{
    size         = "32G"
    type         = "virtio"
    storage      = "local"
    iothread     = 0
    ssd          = 0
    discard      = "on"
  }]
}

variable "memory" {
  description = "memory amount to add (in MB)."
  type        = number
  default     = 2048
}

variable "cpu_sockets" {
  description = "cpu sockets to assign."
  type        = number
  default     = 1
}

variable "cpu_cores" {
  description = "cpu cores to assign."
  type        = number
  default     = 2
}

variable "agent" {
  description = "enable the qemu-guest-agent."
  type        = number
  default     = 1
}

variable "username" {
  description = "user to add during cloudinit."
  type        = string
  default     = ""
}

variable "password" {
  description = "user password to add during cloudinit."
  type        = string
  default     = ""
  sensitive   = true
}

variable "nameserver" {
  description = "nameserver to add during cloudinit."
  type        = string
  default     = ""  
}

variable "ssh_authorized_key" {
  description = "ssh_authorized_key to add during cloudinit."
  type        = string
  default     = ""
}