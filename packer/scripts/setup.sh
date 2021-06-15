#!/bin/bash
set -x
#wait for box - 30
sleep 15

K3S_VERSION="v1.21.1+k3s1"

# add tailscale repo
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list

# base packages
sudo apt update -y && \
sudo apt install -y curl vim jq git make unzip wget docker.io tailscale awscli 
sudo usermod -aG docker $USER

# add k3s binary
curl -sL -o usr/bin/k3s https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}/k3s

exit 0