#!/bin/bash

# Depends on install-cilium-cli.sh.

set -e

export CILIUM_VERSION="1.11.1"

cilium install

# test
echo
echo "Creating cilium-test namespace"
kubectl create ns cilium-test || true
echo
echo "Applying cilium connectivity check"
kubectl apply -n cilium-test -f https://raw.githubusercontent.com/cilium/cilium/v${CILIUM_VERSION}/examples/kubernetes/connectivity-check/connectivity-check.yaml

echo
kubectl -n cilium-test get pods -o wide