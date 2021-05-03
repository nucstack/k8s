
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

TODO - Policy Failures:
```
FAIL - /app/cluster/apps/home-automation/floorplan/floorplan.yaml - containers_securitycontext_readonlyrootfilesystem_true - floorplan in the Deployment floorplan is not using a read only root filesystem
FAIL - /app/cluster/apps/observability/rsyslog/rsyslog.yaml - containers_securitycontext_readonlyrootfilesystem_true - rsyslog in the Deployment rsyslog is not using a read only root filesystem
FAIL - /app/cluster/core/security/openldap/openldap.yaml - containers_securitycontext_readonlyrootfilesystem_true - openldap in the Deployment openldap is not using a read only root filesystem
FAIL - /app/cluster/core/security/openldap/openldap.yaml - containers_securitycontext_readonlyrootfilesystem_true - phpldapadmin in the Deployment openldap is not using a read only root filesystem
FAIL - /app/cluster/apps/observability/rtlamr-collect/rtlamr-collect.yaml - containers_securitycontext_readonlyrootfilesystem_true - rtlamr-collect in the Deployment rtlamr-collect is not using a read only root filesystem
FAIL - /app/cluster/core/security/openldap/openldap.yaml - containers_resources_limits_memory - openldap in the Deployment openldap does not have a memory limit set
FAIL - /app/cluster/core/security/openldap/openldap.yaml - containers_resources_limits_memory - phpldapadmin in the Deployment openldap does not have a memory limit set
FAIL - /app/cluster/apps/home-automation/floorplan/floorplan.yaml - containers_securitycontext_capabilities_drop_index_all - floorplan in the Deployment floorplan doesn't drop all capabilities
FAIL - /app/cluster/apps/observability/rsyslog/rsyslog.yaml - containers_securitycontext_capabilities_drop_index_all - rsyslog in the Deployment rsyslog doesn't drop all capabilities
FAIL - /app/cluster/base/flux-system/gotk-components.yaml - containers_securitycontext_capabilities_drop_index_all - manager in the Deployment helm-controller doesn't drop all capabilities
FAIL - /app/cluster/base/flux-system/gotk-components.yaml - containers_securitycontext_capabilities_drop_index_all - manager in the Deployment kustomize-controller doesn't drop all capabilities
FAIL - /app/cluster/base/flux-system/gotk-components.yaml - containers_securitycontext_capabilities_drop_index_all - manager in the Deployment notification-controller doesn't drop all capabilities
FAIL - /app/cluster/base/flux-system/gotk-components.yaml - containers_securitycontext_capabilities_drop_index_all - manager in the Deployment source-controller doesn't drop all capabilities
FAIL - /app/cluster/core/security/openldap/openldap.yaml - containers_securitycontext_capabilities_drop_index_all - openldap in the Deployment openldap doesn't drop all capabilities
FAIL - /app/cluster/core/security/openldap/openldap.yaml - containers_securitycontext_capabilities_drop_index_all - phpldapadmin in the Deployment openldap doesn't drop all capabilities
FAIL - /app/cluster/apps/observability/rtlamr-collect/rtlamr-collect.yaml - containers_securitycontext_capabilities_drop_index_all - rtlamr-collect in the Deployment rtlamr-collect doesn't drop all capabilities
FAIL - /app/cluster/apps/observability/rtlamr-collect/rtlamr-collect.yaml - cis_5_2_1 - rtlamr-collect in the Deployment rtlamr-collect is privileged
FAIL - /app/cluster/apps/observability/rtlamr-collect/rtlamr-collect.yaml - containers_securitycontext_privileged_true - rtlamr-collect in the Deployment rtlamr-collect is privileged
FAIL - /app/cluster/core/security/openldap/openldap.yaml - containers_resources_limits_cpu - openldap in the Deployment openldap does not have a CPU limit set
FAIL - /app/cluster/core/security/openldap/openldap.yaml - containers_resources_limits_cpu - phpldapadmin in the Deployment openldap does not have a CPU limit set
```