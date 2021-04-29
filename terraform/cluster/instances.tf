// define our tfvars
variable name              {}
variable description       {}
variable username          {}
variable password          {}
variable environment       {}
variable instances         {}
variable template          {}
variable cpu_sockets       {}
variable cpu_cores         {}
variable memory            {}
variable disk              {}
variable network           {}
variable nameserver        {}

module "k8s" {
  source      = "../modules/proxmox-vm"

  name              = var.name
  description       = var.description
  instances         = var.instances
  environment       = var.environment
  template          = var.template
  username          = var.username
  password          = var.password

  // resources    
  cpu_sockets       = var.cpu_sockets 
  cpu_cores         = var.cpu_cores 
  memory            = var.memory
  disk              = var.disk

  // network  
  network           = var.network
  nameserver        = var.nameserver
}