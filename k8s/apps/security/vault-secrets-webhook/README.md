```
export K8S_HOST="$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.server}')"
export K8S_CA_CRT=$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 -d)
export VAULT_SA_NAME=$(kubectl get sa vault-vswh-sa -n security --output jsonpath="{.secrets[*]['name']}")
export VAULT_SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -n security --output 'go-template={{ .data.token }}' | base64 -d)

vault policy write testapp-kv-ro - <<EOF
path "secret/data/testapp/*" {
    capabilities = ["read", "list"]
}
EOF

vault kv put secret/testapp/config \
  username='appuser' \
  password='somesecret' \
  ttl='30s'

vault auth enable kubernetes

vault write auth/kubernetes/config \
token_reviewer_jwt="$VAULT_SA_JWT_TOKEN" \
kubernetes_host="$K8S_HOST" \
kubernetes_ca_cert="$K8S_CA_CRT" \
issuer="https://kubernetes.default.svc.cluster.local"

vault write auth/kubernetes/role/default \
bound_service_account_names=vault-vswh-sa \
bound_service_account_namespaces=security \
policies=testapp-kv-ro \
ttl=24h
```
