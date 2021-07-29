
resource "null_resource" "node_info" {
  count = length(var.instances)

  provisioner "file" {
    source      = "authorized_keys"
    destination = "/home/${var.username != "" ? var.username : random_pet.username.id}/.ssh/authorized_keys"
    content     = var.ssh_authorized_key != "" ? var.ssh_authorized_key : tls_private_key.ssh_key.public_key_openssh

    connection {
      type        = "ssh"
      user        = var.username != "" ? var.username : random_pet.username.id
      password    = var.password != "" ? var.password : random_password.password.result
      host        = var.type == "virtual" ? element(proxmox_vm_qemu.vm, count.index).ssh_host : element(var.instances, count.index)
    }
  }

  triggers = {
    name               = format("%s-%s", var.name, element(random_string.suffix, count.index).result)
    username           = var.username != "" ? var.username : random_pet.username.id
    ipaddress          = var.type == "virtual" ? element(proxmox_vm_qemu.vm, count.index).ssh_host : element(var.instances, count.index)
    ssh_authorized_key = var.ssh_authorized_key != "" ? var.ssh_authorized_key : tls_private_key.ssh_key.public_key_openssh
  }
}
