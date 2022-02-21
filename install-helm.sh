#!/bin/bash

set -e

export HELM_VERSION="v3.8.0"

URL="https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz"

curl --silent --location "${URL}" | tar xz -C /tmp
cp /tmp/linux-amd64/helm $HOME/bin/