
# resource "null_resource" "infrastructure" {
#   count = var.type == "physical" ? length(var.instances) : 0

#   provisioner "file" {
#     source      = "authorized_keys"
#     destination = "/home/${var.username != "" ? var.username : random_pet.username.id}/.ssh/authorized_keys"
#     content     = var.ssh_authorized_key != "" ? var.ssh_authorized_key : tls_private_key.ssh_key.public_key_openssh

#     connection {
#       type        = "ssh"
#       user        = var.username != "" ? var.username : random_pet.username.id
#       password    = var.password != "" ? var.password : random_password.password.result
#       host        = element(var.instances, count.index)
#     }
#   }

#   triggers = {
#     name               = format("%s-%s", var.name, element(random_string.suffix, count.index).result)
#     username           = var.username != "" ? var.username : random_pet.username.id
#     ipaddress          = element(var.instances, count.index)
#     ssh_authorized_key = var.ssh_authorized_key != "" ? var.ssh_authorized_key : tls_private_key.ssh_key.public_key_openssh
#   }
# }
