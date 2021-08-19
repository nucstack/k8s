terraform {
  experiments = [
    // allows optional object() attributes
    module_variable_optional_attrs
  ]
}
locals {
  // a generalized list of private/public subnets
  private_subnets = concat(
    local.aws_private_subnets
  )
  public_subnets = concat(
    local.aws_public_subnets
  )
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
    hostnames   = var.type == "aws" ? join(",", module.ec2-instances[each.key].private_dns) : join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): format("%s-%d", each.value.name, i+1)])
    ipaddresses = var.type == "aws" ? join(",", module.ec2-instances[each.key].private_ip)  : join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): cidrhost(each.value.subnet, instance)])
  }
}
