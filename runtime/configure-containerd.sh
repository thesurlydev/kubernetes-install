#!/usr/bin/env bash

set -e

source /home/shane/common.sh

echo -e "${LG}Configuring containerd and start service...${NC}"
mkdir -p /etc/containerd
containerd config default>/etc/containerd/config.toml

# TODO untested!
echo -e "${LG}Settings SystemdCgroup to 'true'...${NC}"
sed -i  "s/SystemdCgroup = false/SystemdCgroup = true/" /etc/containerd/config.toml;

echo -e "${LG}Restarting containerd service...${NC}"
systemctl restart containerd
systemctl enable containerd
systemctl status containerd