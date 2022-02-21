
// variables

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

// ssh keys used to auth against provisioned hosts
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// generate an ansible inventory file from the hosts
data "template_file" "k3s_inventory" {
  for_each = {for s in var.services: s.name => s}
  template = file("./templates/k3s-inventory.ini.tmpl")
  vars     = {
    masters     = var.masters
    hostnames   = join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): format("%s-%d", each.value.name, i+1)])
    ipaddresses = join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): cidrhost(each.value.subnet, instance)])
  }
}

// hack helper resource to store the attributes
// we care about for either cloud/physical
// resources for easer general parsability
resource "null_resource" "hosts" {
  for_each = {for s in var.services: s.name => s}
  triggers = {
    username    = var.ssh_username
    hostnames   = join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): format("%s-%d", each.value.name, i+1)])
    ipaddresses = join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): cidrhost(each.value.subnet, instance)])
  }
}
