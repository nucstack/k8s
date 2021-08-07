
## K8S Home Deployment
Originally created from [this](https://github.com/k8s-at-home/template-cluster-k3s) template. Most of the decisions came from the fantastic list of projects [here](https://github.com/k8s-at-home/awesome-home-kubernetes).

Main Deviations from this template:
 - Replaced k3s deployment with submoduled kubespray
 - flipped .envrc to be untracked
 - Added a devcontainer image with all deps
 - Added tasks to simplify deployment/bootstrap/initialize/secrets reroll
 - added `git-crypt` to allow for tracked encryption of secret things

**Provisioning the cluster**
```bash
cp .env.example .env
task ansible:k8s-install
```

**Rerolling secrets**
```bash
task flux:app-secrets # FILTER=home-assistant
task flux:shared-secrets
```

**Flux**
```bash
task flux:bootstrap
task flux:install
```
