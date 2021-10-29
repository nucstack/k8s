```
export K8S_HOST="$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.server}')"
export VAULT_SA_NAME=$(kubectl get sa vault-vswh-sa -n security --output jsonpath="{.secrets[*]['name']}")
export VAULT_SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -n security --output 'go-template={{ .data.token }}' | base64 -d)
export K8S_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -n security -o jsonpath="{.data['ca\.crt']}" | base64 -d; echo)

vault auth enable kubernetes

vault write auth/kubernetes/config \
token_reviewer_jwt="$VAULT_SA_JWT_TOKEN" \
kubernetes_host="$K8S_HOST" \
kubernetes_ca_cert="$K8S_CA_CRT" \
issuer="https://kubernetes.default.svc.cluster.local"

vault secrets enable -version=2 -path=secrets kv

vault kv put /secrets/myapp username=foo password=bar

vault policy write myapp-read-policy - <<EOF
path "secrets/data/myapp" {
    capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/vault-secrets-webhook \
  bound_service_account_names=default \
  bound_service_account_namespaces=default \
  policies=myapp-read-policy \
  ttl=24h
```
