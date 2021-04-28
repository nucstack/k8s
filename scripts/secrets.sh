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

# floorplan
envsubst < ./cluster/apps/home-automation/floorplan/floorplan.secrets.enc.template > ./cluster/apps/home-automation/floorplan/floorplan.secrets.enc.yaml
sops --encrypt --in-place ./cluster/apps/home-automation/floorplan/floorplan.secrets.enc.yaml

# home-assistant
envsubst < ./cluster/apps/home-automation/home-assistant/home-assistant.secrets.enc.template > ./cluster/apps/home-automation/home-assistant/home-assistant.secrets.enc.yaml
sops --encrypt --in-place ./cluster/apps/home-automation/home-assistant/home-assistant.secrets.enc.yaml

# mosquitto
envsubst < ./cluster/apps/home-automation/mosquitto/mosquitto.secrets.enc.template > ./cluster/apps/home-automation/mosquitto/mosquitto.secrets.enc.yaml
sops --encrypt --in-place ./cluster/apps/home-automation/mosquitto/mosquitto.secrets.enc.yaml

# zigbee2mqtt
envsubst < ./cluster/apps/home-automation/zigbee2mqtt/zigbee2mqtt.secrets.enc.template > ./cluster/apps/home-automation/zigbee2mqtt/zigbee2mqtt.secrets.enc.yaml
sops --encrypt --in-place ./cluster/apps/home-automation/zigbee2mqtt/zigbee2mqtt.secrets.enc.yaml

# zwavejs2mqtt
envsubst < ./cluster/apps/home-automation/zwavejs2mqtt/zwavejs2mqtt.secrets.enc.template > ./cluster/apps/home-automation/zwavejs2mqtt/zwavejs2mqtt.secrets.enc.yaml
sops --encrypt --in-place ./cluster/apps/home-automation/zwavejs2mqtt/zwavejs2mqtt.secrets.enc.yaml

# kube-prometheus-stack
envsubst < ./cluster/apps/observability/kube-prometheus-stack/grafana-ldap.secret.enc.template > ./cluster/apps/observability/kube-prometheus-stack/grafana-ldap.secret.enc.yaml
sops --encrypt --in-place ./cluster/apps/observability/kube-prometheus-stack/grafana-ldap.secret.enc.yaml

# influxdb
envsubst < ./cluster/apps/observability/influxdb/influxdb.secret.enc.template > ./cluster/apps/observability/influxdb/influxdb.secret.enc.yaml
sops --encrypt --in-place ./cluster/apps/observability/influxdb/influxdb.secret.enc.yaml

# openldap
envsubst < ./cluster/core/security/openldap/openldap.secret.enc.template > ./cluster/core/security/openldap/openldap.secret.enc.yaml
sops --encrypt --in-place ./cluster/core/security/openldap/openldap.secret.enc.yaml

# rtlamr-collect
envsubst < ./cluster/apps/observability/rtlamr-collect/rtlamr-collect.secrets.enc.template > ./cluster/apps/observability/rtlamr-collect/rtlamr-collect.secrets.enc.yaml
sops --encrypt --in-place ./cluster/apps/observability/rtlamr-collect/rtlamr-collect.secrets.enc.yaml