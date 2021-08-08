
# module "k8s" {
#   count             = var.type == "physical" ? 1 : 0
#   source            = "../modules/instance"
#   type              = var.type
#   instances         = var.instances
#   environment       = var.environment
#   username          = var.username
#   password          = var.password
# }
