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