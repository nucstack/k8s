#!/usr/bin/env bash
envsubst < ./tmpl/cluster-settings.yaml > ./cluster/base/cluster-settings.yaml
envsubst < ./tmpl/cluster-secrets.yaml > ./cluster/base/cluster-secrets.yaml
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

# Kube-prometheus-stack
envsubst < ./cluster/apps/observability/kube-prometheus-stack/grafana-ldap.secret.enc.template > ./cluster/apps/observability/kube-prometheus-stack/grafana-ldap.secret.enc.yaml
sops --encrypt --in-place ./cluster/apps/observability/kube-prometheus-stack/grafana-ldap.secret.enc.yaml

# influxdb
envsubst < ./cluster/apps/observability/influxdb/influxdb.secret.enc.template > ./cluster/apps/observability/influxdb/influxdb.secret.enc.yaml
sops --encrypt --in-place ./cluster/apps/observability/influxdb/influxdb.secret.enc.yaml

# openldap
envsubst < ./cluster/core/security/openldap/openldap.secret.enc.template > ./cluster/core/security/openldap/openldap.secret.enc.yaml
sops --encrypt --in-place ./cluster/core/security/openldap/openldap.secret.enc.yaml