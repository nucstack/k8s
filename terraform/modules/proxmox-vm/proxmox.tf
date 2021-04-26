
resource "proxmox_vm_qemu" "vm" {
  count       = length(var.instances)
  os_type     = var.os_type
  target_node = var.target_node
  name        = format("%s-%s", var.name, element(random_string.suffix, count.index).result)
  desc        = var.description
  pool        = var.pool
  clone       = var.template
  agent       = var.agent
  cores       = var.cpu_cores
  sockets     = var.cpu_sockets
  memory      = var.memory
  onboot      = var.onboot
  full_clone  = var.full_clone
  clone_wait  = 30

  # Setup disks
  dynamic "disk" {
  for_each = var.disk != null ? var.disk : []
    content {
      size         = lookup(disk.value, "size", "32G")
      type         = lookup(disk.value, "type", "virtio")
      storage      = lookup(disk.value, "storage", "local")
      iothread     = tonumber(lookup(disk.value, "iothread", 0))
      ssd          = tonumber(lookup(disk.value, "ssd", 0))
      discard      = lookup(disk.value, "discard", "on")
    }
  }

  # Setup networks
  dynamic "network" {
  for_each = var.network != null ? var.network : []
    content {
      model  = lookup(network.value, "model", "virtio")
      bridge = lookup(network.value, "bridge", "vmbr0")
      tag    = tonumber(lookup(network.value, "tag", 0))
    }
  }

  # Setup cloud-init
  ipconfig0  = element(var.instances, count.index)
  nameserver = var.nameserver
  ciuser     = var.username != "" ? var.username : random_pet.username.id
  cipassword = var.password != "" ? var.password : random_password.password.result  
  sshkeys    = tls_private_key.ssh_key.public_key_openssh
}