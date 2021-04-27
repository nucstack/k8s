#!/usr/bin/env bash

environment=${environment:-staging}
playbook=${playbook:-kubespray}

playbook_path="/app/external/${playbook}"
kubeconfig_path="${playbook_path}/inventory/${environment}/artifacts/external_kubeconfig"

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

  -e "kubeconfig_localhost=true ${extra_vars}" \
  "${playbook_path}/cluster.yml" -b -v \
  --private-key="/app/terraform/k8s-cluster/${environment}_ssh_private_key"

sleep 60

# # pre flight check
flux --kubeconfig="${kubeconfig_path}" check --pre

# # create flux namespace
kubectl --kubeconfig="${kubeconfig_path}" create namespace flux-system --dry-run=client -o yaml | kubectl --kubeconfig="${kubeconfig_path}" apply -f -

# # create secret from gpg key
gpg --export-secret-keys --armor "${FLUX_KEY_FP}" |
kubectl --kubeconfig="${kubeconfig_path}" create secret generic sops-gpg \
    --namespace=flux-system \
    --from-file=sops.asc=/dev/stdin

# # generate configs/secrets from envs
envsubst < ./tmpl/.sops.yaml > ./.sops.yaml
envsubst < ./tmpl/cluster-secrets.yaml > ./cluster/base/cluster-secrets.yaml
envsubst < ./tmpl/cluster-settings.yaml > ./cluster/base/cluster-settings.yaml
envsubst < ./tmpl/gotk-sync.yaml > ./cluster/base/flux-system/gotk-sync.yaml
envsubst < ./tmpl/secret.enc.yaml > ./cluster/core/cert-manager/secret.enc.yaml

# # generate encrypted secrets
sops --encrypt --in-place ./cluster/base/cluster-secrets.yaml
sops --encrypt --in-place ./cluster/core/cert-manager/secret.enc.yaml

kubectl --kubeconfig="${kubeconfig_path}" apply --kustomize=./cluster/base/flux-system