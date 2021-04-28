#!/usr/bin/env bash
envsubst < ./tmpl/cluster-secrets.yaml > ./cluster/base/cluster-secrets.yaml
envsubst < ./tmpl/cluster-settings.yaml > ./cluster/base/cluster-settings.yaml
sops --encrypt --in-place ./cluster/base/cluster-secrets.yaml

# authelia
envsubst < ./cluster/core/security/authelia/authelia.secret.enc.template > ./cluster/core/security/authelia/authelia.secret.enc.yaml
sops --encrypt --in-place ./cluster/core/security/authelia/authelia.secret.enc.yaml

envsubst < ./cluster/core/security/authelia/authelia-postgres.secret.enc.template > ./cluster/core/security/authelia/authelia-postgres.secret.enc.yaml
sops --encrypt --in-place ./cluster/core/security/authelia/authelia-postgres.secret.enc.yaml

envsubst < ./cluster/core/security/authelia/authelia-redis.secret.enc.template > ./cluster/core/security/authelia/authelia-redis.secret.enc.yaml
sops --encrypt --in-place ./cluster/core/security/authelia/authelia-redis.secret.enc.yaml

# botkube
envsubst < ./cluster/apps/observability/botkube/botkube.secrets.enc.template > ./cluster/apps/observability/botkube/botkube.secrets.enc.yaml
sops --encrypt --in-place ./cluster/apps/observability/botkube/botkube.secrets.enc.yaml

# kube-prometheus-stack
envsubst < ./cluster/apps/observability/kube-prometheus-stack/grafana-ldap-config.secrets.enc.template > ./cluster/apps/observability/kube-prometheus-stack/grafana-ldap-config.secrets.enc.yaml
sops --encrypt --in-place ./cluster/apps/observability/kube-prometheus-stack/grafana-ldap-config.secrets.enc.yaml

envsubst < ./cluster/apps/observability/kube-prometheus-stack/grafana-datasources.secrets.enc.template > ./cluster/apps/observability/kube-prometheus-stack/grafana-datasources.secrets.enc.yaml
sops --encrypt --in-place ./cluster/apps/observability/kube-prometheus-stack/grafana-datasources.secrets.enc.yaml

# openldap
envsubst < ./cluster/core/security/openldap/openldap.secret.enc.template > ./cluster/core/security/openldap/openldap.secret.enc.yaml
sops --encrypt --in-place ./cluster/core/security/openldap/openldap.secret.enc.yaml