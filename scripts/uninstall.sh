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

# uninstall k3s master
if [[ ! -z ${master} ]]; then
  ssh k3s@${master} -i "terraform/k3s-cluster/${environment}_ssh_private_key" k3s-uninstall.sh
fi

# uninstall k3s nodes
if [[ ! -z ${nodes} ]]; then
  for node in ${nodes//,/ } ; do
    ssh k3s@${node} -i "terraform/k3s-cluster/${environment}_ssh_private_key" k3s-agent-uninstall.sh
  done
fi