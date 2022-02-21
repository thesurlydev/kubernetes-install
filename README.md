# Kubernetes Install

A collection of helper scripts to install kubernetes on a small bare metal cluster.

Tested on Ubuntu 20.04 with `lvm2` package installed.

## Ingredients

* 4 - Intel NUC nodes with Ubuntu 20.04 and lvm2 package installed.
* Kubernetes installed via `kubeadm`
* Cilium and Hubble
* Rook and Ceph (TODO)

## Procedure

The following scripts should be run in the order presented below:

1. master node: `install-master.sh`
2. worker nodes: `install-worker.sh`
3. For each node that needs to connect to the cluster, copy the master `~/.kube/config file`.
4. workstation (configured to point at the new cluster): `install-cilium-cli.sh`
5. workstation: `install-cilium.sh`
6. workstation: `install-hubble-client.sh`
7. `install-rook.sh`

## Joining Worker Nodes

From master (nuc1):

```bash
kubeadm token create --print-join-command > join
scp join nuc2:/home/shane/
scp join nuc3:/home/shane/
scp join nuc4:/home/shane/
```

where nuc2, nuc3 and nuc4 are the worker nodes.

From worker(s):

```bash
export J=$(cat join)
(sudo $J)
```
