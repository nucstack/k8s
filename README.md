
## K8S Home Deployment
Originally created from [this](https://github.com/k8s-at-home/template-cluster-k3s) template. Most of the decisions came from the fantastic list of projects [here](https://github.com/k8s-at-home/awesome-home-kubernetes).

Main Deviations from this template:
 - Replaced k3s deployment with submoduled kubespray
 - Added basic terraform to provision environments. (I use proxmox on cheap local hardware for my staging environment.)
 - flipped .envrc to be untracked
 - Added a builder docker image with all deps ( I know, gross but it works for my needs)
 - Added tasks to simplify deployment/bootstrap/initialize/secrets reroll
 - Added raspernetes `k8s-security-policies` and conftest
 - added `git-crypt` to allow for tracked encryption of secret things
