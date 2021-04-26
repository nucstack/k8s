#!/usr/bin/env bash

set -eou pipefail

kubectl --kubeconfig=./kubeconfig apply --kustomize=./cluster/base/flux-system

# TODO: remove this double run requirement
kubectl --kubeconfig=./kubeconfig apply --kustomize=./cluster/base/flux-system