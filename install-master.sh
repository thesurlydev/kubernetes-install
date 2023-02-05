#!/bin/bash

# Bare metal install of Kubernetes on Ubuntu 20.04.x LTS

set -e

echo
echo "Installing prerequisites"
sudo apt update
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release net-tools software-properties-common -y

echo 
echo "Installing kubectl, kubeadm, kubelet"
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl || true


echo "Disabling swap"
sudo swapoff -a

echo 
echo "Applying sysctl params without reboot"
sudo sysctl --system

# idempotent
sudo kill -9 $(ps -ef | awk '/kube/ {print $2}') || true
sudo rm -rf /etc/kubernetes/manifests
sudo rm -rf /etc/etcd
sudo rm -rf /var/lib/etcd

sudo mkdir -p /var/lib/kubelet
echo "KUBELET_KUBEADM_ARGS=\"--cgroup-driver=systemd --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.2 --resolv-conf=/run/systemd/resolve/resolv.conf\"" | sudo tee /var/lib/kubelet/kubeadm-flags.env
sudo kubeadm init -v=6

echo
echo "Copying kubernetes config"
rm -rf $HOME/.kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config





