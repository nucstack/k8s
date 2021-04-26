
// generate username/password
resource "random_pet" "username" {
  length = 1
}
resource "random_password" "password" {
  length  = 16
  special = true
}

// generate random strings for instance names
resource "random_string" "suffix" {
  count   = length(var.instances)
  length  = 6
  upper   = false
  lower   = true
  special = false
}
