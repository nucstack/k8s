
## K8S Home Deployment
Originally created from [this](https://github.com/k8s-at-home/template-cluster-k3s) template.

Main Changes:
 - Replaced k3s with submoduled kubespray
 - Added basic terraform to provision staging environment. (I use proxmox on cheap local hardware)
 - flipped .envrc to be untracked
 - Added a builder docker image with all deps ( I know, gross)
 - Added bootstrap/initialize/secrets scripts for re-rollability purposes