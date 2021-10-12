#!/usr/bin/env zsh

export KIND_VERSION=v0.11.1
curl -fsSL -o /usr/local/bin/kind \
    "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
chmod +x /usr/local/bin/kind
kind --version

export KUBEDD_VERSION=v0.1.1
curl -fsSL "https://github.com/devtron-labs/silver-surfer/releases/download/${KUBEDD_VERSION}/silver-surfer_${KUBEDD_VERSION}_linux_amd64.tar.gz" \
    | tar xvz --overwrite --file - --directory /tmp
mv /tmp/kubedd /usr/local/bin/kubedd
kubedd --version

export KUSTOMIZER_VERSION=v1.1.1
curl -fsSL "https://github.com/stefanprodan/kustomizer/releases/download/${KUSTOMIZER_VERSION}/kustomizer_${KUSTOMIZER_VERSION}_linux_amd64.tar.gz" \
    | tar xvz --overwrite --file - --directory /tmp
mv /tmp/kustomizer /usr/local/bin/kustomizer
kustomizer --version

export SOPS_VERSION=v3.7.1
curl -fsSL -o /usr/local/bin/sops \
    "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux"
chmod +x /usr/local/bin/sops
sops --version

export TASK_VERSION=v3.9.0
curl -fsSL "https://github.com/go-task/task/releases/download/${TASK_VERSION}/task_linux_amd64.tar.gz" \
    | tar xvz --overwrite --file - --directory /tmp
mv /tmp/task /usr/local/bin/task
task --version

export VELERO_VERSION=v1.7.0
curl -fsSL "https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/velero-${VELERO_VERSION#*v}-linux-amd64.tar.gz" \
    | tar xvz --overwrite --file - --strip-components=1 --directory /tmp
mv /tmp/velero /usr/local/bin/velero
velero --version

rm -rf /tmp/*
