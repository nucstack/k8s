
module "k8s" {
  source      = "../modules/instance"

  type              = var.type
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