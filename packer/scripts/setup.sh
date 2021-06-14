#!/bin/bash
set -x
#wait for box - 30
sleep 15

# add tailscale repo
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list

# base packages
sudo apt update -y && \
sudo apt install -y curl vim jq git make unzip wget docker.io tailscale awscli 
sudo usermod -aG docker $USER

# install k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_ENABLE="true" INSTALL_K3S_SKIP_START="true" sh -

exit 0