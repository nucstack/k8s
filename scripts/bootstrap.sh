#!/usr/bin/env bash

environment=${environment:-staging}

# args
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"        
   fi

  shift
done

echo "environment:${environment}"
echo "master:${master}"
echo "nodes:${nodes}"

# setup k3s master
if [[ ! -z ${master} ]]; then   
  k3sup install --host=${master} \
    --user=k3s \
    --k3s-version=v1.20.5+k3s1 \
    --ssh-key "terraform/k3s-cluster/${environment}_ssh_private_key" \
    --k3s-extra-args="--disable servicelb --disable traefik"
fi

# setup k3s nodes
if [[ ! -z ${nodes} ]]; then
  for node in ${nodes//,/ } ; do 
    k3sup join \
      --host="${node}" \
      --server-host="${master}" \
      --k3s-version=v1.20.5+k3s1 \
      --user=k3s \
      --ssh-key "terraform/k3s-cluster/${environment}_ssh_private_key"
  done
fi

# pre flight check
flux --kubeconfig=./kubeconfig check --pre

# create flux namespace
kubectl --kubeconfig=./kubeconfig create namespace flux-system --dry-run=client -o yaml | kubectl --kubeconfig=./kubeconfig apply -f -

# create secret from gpg key
gpg --export-secret-keys --armor "${FLUX_KEY_FP}" |
kubectl --kubeconfig=./kubeconfig create secret generic sops-gpg \
    --namespace=flux-system \
    --from-file=sops.asc=/dev/stdin

# generate configs/secrets from envs
envsubst < ./tmpl/.sops.yaml > ./.sops.yaml
envsubst < ./tmpl/cluster-secrets.yaml > ./cluster/base/cluster-secrets.yaml
envsubst < ./tmpl/cluster-settings.yaml > ./cluster/base/cluster-settings.yaml
envsubst < ./tmpl/gotk-sync.yaml > ./cluster/base/flux-system/gotk-sync.yaml
envsubst < ./tmpl/secret.enc.yaml > ./cluster/core/cert-manager/secret.enc.yaml

# generate encrypted secrets
sops --encrypt --in-place ./cluster/base/cluster-secrets.yaml
sops --encrypt --in-place ./cluster/core/cert-manager/secret.enc.yaml
