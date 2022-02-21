terraform {
  experiments = [
    // allows optional object() attributes
    module_variable_optional_attrs
  ]
}

// ssh keys used to auth against provisioned instances
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// hack helper resource to store the attributes
// we care about for either cloud/physical
// resources for easer general parsability
resource "null_resource" "instances" {
  for_each = {for s in var.services: s.name => s}
  triggers = {
    username    = var.ssh_username
    hostnames   = join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): format("%s-%d", each.value.name, i+1)])
    ipaddresses = join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): cidrhost(each.value.subnet, instance)])
  }
}

// generate an ansible inventory file from the hosts
data "template_file" "ansible_inventory" {
  for_each = {for s in var.services: s.name => s}
  template = file("./templates/k3s-inventory.ini.tmpl")
  vars     = {
    masters     = var.masters
    hostnames   = join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): format("%s-%d", each.value.name, i+1)])
    ipaddresses = join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): cidrhost(each.value.subnet, instance)])
  }
}
