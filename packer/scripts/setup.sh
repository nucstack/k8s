#!/bin/bash
set -x
#wait for box - 30
sleep 15

K3S_VERSION="v1.21.1+k3s1"

# base packages
sudo apt update -y && \
sudo apt install -y curl vim jq git make unzip wget docker.io awscli 
sudo usermod -aG docker $USER

# add k3s binary
curl -sL -o /usr/bin/k3s https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}/k3s
chmod +x /usr/bin/k3s

exit 0