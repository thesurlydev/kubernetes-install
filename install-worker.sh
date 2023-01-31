#!/usr/bin/env bash

# Bare metal install of Kubernetes on Ubuntu 20.04.x LTS

set -e

source common.sh

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


# install containerd. 
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

echo 
echo "Applying sysctl params without reboot"
sudo sysctl --system

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
echo 
echo "Uninstalling old versions of Docker"
sudo apt-get remove docker docker-engine docker.io containerd runc -y

echo 
echo "Adding Docker's official GPG key"
sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo 
echo "Installing Docker and containerd.io"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

echo 
echo "Verifying Docker Engine is installed correctly"
sudo docker run hello-world

echo 
echo "Applying containerd default config"
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

# idempotent
sudo kill -9 $(ps -ef | awk '/kube/ {print $2}') || true
sudo rm -rf /etc/kubernetes/manifests
sudo rm -rf /etc/etcd
sudo rm -rf /var/lib/etcd

sudo mkdir -p /var/lib/kubelet
echo "KUBELET_KUBEADM_ARGS=\"--cgroup-driver=systemd --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.2 --resolv-conf=/run/systemd/resolve/resolv.conf\"" | sudo tee /var/lib/kubelet/kubeadm-flags.env
#sudo kubeadm init -v=6

echo
echo "Setting up kubernetes config directory"
rm -rf $HOME/.kube
mkdir -p $HOME/.kube


echo
echo "Done!"
