
// Common Variables

variable role {
  type        = string
  description = "images primary role"
  default     = "tailscale-relay"
}

variable tags {
  type = map(string)
  default = {
    role = "tailscale-relay"
  }
}

// AWS
data "amazon-ami" "base-image" {
  filters = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "us-east-2"
}

source "amazon-ebs" "amazon-ebs" {
  ami_description             = "role:${var.role}"
  ami_name                    = "${var.role}-{{ timestamp }}"
  ami_regions                 = ["us-east-2"]
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  force_delete_snapshot       = true
  force_deregister            = true
  instance_type               = "t2.micro"
  region                      = "us-east-2"
  source_ami                  = data.amazon-ami.base-image.id
  spot_price                  = "0"
  ssh_pty                     = true
  ssh_timeout                 = "5m"
  ssh_username                = "ubuntu"
  tags                        = var.tags
}

// GCP
// TBD

// Azure
// TBD

build {
  sources = ["source.amazon-ebs.amazon-ebs"]

  provisioner "shell" {
    script = "scripts/tailscale-relay-setup.sh"
  }

  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

}
