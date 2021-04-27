#!/usr/bin/env bash

# authelia
envsubst < ./cluster/core/security/authelia/authelia.secret.enc.template > ./cluster/core/security/authelia/authelia.secret.enc.yaml
sops --encrypt --in-place ./cluster/core/security/authelia/authelia.secret.enc.yaml

envsubst < ./cluster/core/security/authelia/authelia-postgres.secret.enc.template > ./cluster/core/security/authelia/authelia-postgres.secret.enc.yaml
sops --encrypt --in-place ./cluster/core/security/authelia/authelia-postgres.secret.enc.yaml

envsubst < ./cluster/core/security/authelia/authelia-redis.secret.enc.template > ./cluster/core/security/authelia/authelia-redis.secret.enc.yaml
sops --encrypt --in-place ./cluster/core/security/authelia/authelia-redis.secret.enc.yaml

# openldap
envsubst < ./cluster/core/security/openldap/openldap.secret.enc.template > ./cluster/core/security/openldap/openldap.secret.enc.yaml
sops --encrypt --in-place ./cluster/core/security/openldap/openldap.secret.enc.yaml