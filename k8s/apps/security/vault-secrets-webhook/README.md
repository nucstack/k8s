```
export K8S_HOST="$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.server}')"
export K8S_CA_CRT=$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 -d)
export VAULT_SA_NAME=$(kubectl get sa vault-vswh-sa -n security --output jsonpath="{.secrets[*]['name']}")
export VAULT_SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -n security --output 'go-template={{ .data.token }}' | base64 -d)

vault auth enable kubernetes

vault write auth/kubernetes/config \
token_reviewer_jwt="$VAULT_SA_JWT_TOKEN" \
kubernetes_host="$K8S_HOST" \
kubernetes_ca_cert="$K8S_CA_CRT" \
issuer="https://kubernetes.default.svc.cluster.local"

vault secrets enable -path=secrets kv

vault kv put /secrets/myapp username=foo password=bar

vault policy write myapp-read-policy - <<EOF
path "secrets/*" {
    capabilities = ["read", "list"]
}
EOF

vault write auth/kubernetes/role/vault-secrets-webhook \
  bound_service_account_names=vault-vswh-sa \
  bound_service_account_namespaces=security \
  policies=myapp-read-policy \
  ttl=24h
```
