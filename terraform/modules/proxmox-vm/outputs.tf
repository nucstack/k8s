
output "name" {
  value       = proxmox_vm_qemu.vm.*.name
  description = "vm name"
}

output "ipaddress" {
  value       = proxmox_vm_qemu.vm.*.ssh_host
  description = "ip address"
}

output "ssh_username" {
  value       = proxmox_vm_qemu.vm.*.ciuser
  description = "ssh username"
}

output "ssh_password" {
  value       = proxmox_vm_qemu.vm.*.cipassword
  description = "ssh password"
  sensitive   = true
}

output "ssh_private_key" {
  value       = tls_private_key.ssh_key.*.private_key_pem
  description = "ssh private key"
  sensitive   = true
}