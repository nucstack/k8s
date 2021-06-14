
# Variables

variable base_image {
  type        = string
  description = "reference image"
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable instance_type {
  type        = string
  description = "instance type"
  default     = "t2.micro"
}

variable region {
  type        = string
  description = "region"
  default     = "us-east-2"
}

variable role {
  type        = string
  description = "images primary role"
  default     = "k3s"
}

variable tags {
  type = map(string)
  default = {
    role = "k3s"
  }
}

data "amazon-ami" "base-image" {
  filters = {
    name                = var.base_image
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = var.region
}

source "amazon-ebs" "amazon-ebs" {
  ami_description             = "role:${var.role}"
  ami_name                    = "${var.role}-{{ timestamp }}"
  ami_regions                 = ["${var.region}"]
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  force_delete_snapshot       = true
  force_deregister            = true
  instance_type               = var.instance_type
  region                      = var.region
  source_ami                  = data.amazon-ami.base-image.id
  spot_price                  = "0"
  ssh_pty                     = true
  ssh_timeout                 = "5m"
  ssh_username                = "ubuntu"
  tags                        = var.tags
}

build {
  sources = ["source.amazon-ebs.amazon-ebs"]

  provisioner "shell" {
    script = "scripts/setup.sh"
  }

  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

}
