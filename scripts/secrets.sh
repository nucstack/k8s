#!/usr/bin/env bash

envsubst < ./tmpl/openldap.secret.enc.yaml > ./cluster/core/security/openldap/secret.enc.yaml
sops --encrypt --in-place ./cluster/core/security/openldap/secret.enc.yaml