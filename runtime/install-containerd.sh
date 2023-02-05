#!/usr/bin/env bash

set -e

source common.sh

echo -e "${LG}Configuring persistent loading of modules...${NC}"
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

# Load at runtime
sudo modprobe overlay
sudo modprobe br_netfilter

echo -e "${LG}Ensuring sysctl params are set...${NC}"
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

echo -e "${LG}Reloading configs...${NC}"
sudo sysctl --system

echo -e "${LG}Installing required packages...${NC}"
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

echo -e "${LG}Adding Docker repo...${NC}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo -e "${LG}Installing containerd...${NC}"
sudo apt update
sudo apt install -y containerd.io

