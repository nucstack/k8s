
locals {

  // a generalized list of private/public subnets
  private_subnets = concat(
    local.aws_private_subnets
  )
  public_subnets = concat(
    local.aws_public_subnets
  )
  // TODO: make this a template
  startup_scripts = {
    tailscale-relay = base64encode(<<-EOT
      #!/bin/bash
      echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
      echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
      sudo sysctl -p /etc/sysctl.conf
      sudo systemctl enable --now tailscaled
      sudo tailscale up --authkey "xxxxxx" --advertise-routes=${join(",", local.private_subnets)}
    EOT
    )
    k3s = base64encode(<<-EOT
      #!/bin/bash
      echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
      echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
      sudo sysctl -p /etc/sysctl.conf
      sudo systemctl enable --now tailscaled
      sudo tailscale up --authkey "xxxxxx" --advertise-routes=${join(",", local.private_subnets)}
    EOT
    )
  }
}

// ssh keys used to auth against provisioned instances
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}