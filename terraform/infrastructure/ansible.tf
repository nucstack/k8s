
// generate an ansible inventory file from the hosts
data "template_file" "k3s_inventory" {
  for_each = {for s in var.services: s.name => s}
  template = file("./templates/k3s-inventory.ini.tmpl")
  vars     = {
    masters     = var.masters
    hostnames   = join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): format("%s-%d", each.value.name, i+1)])
    ipaddresses = join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): cidrhost(each.value.subnet, instance)])
  }
}

// hack helper resource to store the attributes
// we care about for either cloud/physical
// resources for easer general parsability
resource "null_resource" "hosts" {
  for_each = {for s in var.services: s.name => s}
  triggers = {
    username    = var.ssh_username
    hostnames   = join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): format("%s-%d", each.value.name, i+1)])
    ipaddresses = join(",", [ for i, instance in range(each.value.start_ip, each.value.start_ip + each.value.count): cidrhost(each.value.subnet, instance)])
  }
}
