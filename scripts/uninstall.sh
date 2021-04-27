#!/usr/bin/env bash

environment=${environment:-staging}
playbook=${playbook:-kubespray}

playbook_path="/app/external/${playbook}"
kubeconfig_path="${playbook_path}/inventory/${environment}/artifacts/admin.conf"

args
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"        
   fi

  shift
done

echo "environment: ${environment}"
echo "playbook: ${playbook}"
echo "user: ${user}"
echo "nodes: ${nodes}"

# setup k8s

# create inventory
CONFIG_FILE="${playbook_path}/inventory/${environment}/hosts.yml" \
python3 "${playbook_path}/contrib/inventory_builder/inventory.py" ${nodes[@]}

# deploy k8s via ansible
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook \
  -i "${playbook_path}/inventory/${environment}/hosts.yml" \
  --become --become-user root \
  -u "${user}" \
  "${playbook_path}/reset.yml" -b -v \
  --private-key="/app/terraform/k8s-cluster/${environment}_ssh_private_key"
