#!/bin/bash

set -e

MASTER_COUNT=2
MASTER_NODE_TYPE=g6-standard-1

WORKER_COUNT=3
WORKER_NODE_TYPE=g6-standard-2

CLUSTER_NAME=dev-minecraft
ENVIRONMENT=dev

lc() {
  linode-cli linodes create --json --pretty --root_pass bXuK86wKv4JXGP0gE5kbGYlHZiSG9c2w/MWH9jzd5Cg= --authorized_keys "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA4A+ki6PaU+SIYpkx5Cm6LtA0Lr05qGstQp2bySh9YU1wodRmcolRIbiaPzfalURrNcFjFfnWW2SuoyF4U3XeA7LCfrnN7T2d0Kp9facA4rSkSW7tSdZIgyo9trRK2d+lgGrr2Hs8wYAaU4D61ptksdVWfgpuPDXDdk90VWVAhP2FeB+EFB7CZxtw7p6TN4YC2GNpBQIPfvGvgnl/9WyrHQU2hMIWMQ9+2XmwMBF9iwpbCAkLhdNUNYrDI6sig9cLIAClvJLCgmHruSy1Ns2FjYbt9avpNulRZu6yBApJGzbF8thBYE0fgOB3gsHLqk+gjR7hGC6ZF68cyUfQIsjghw== rsa-key-20191220" --private_ip true $*
  return $?
}

for N in $(seq $MASTER_COUNT); do
  while ! lc --label master-$N.$CLUSTER_NAME.k --tags k8s --tags k8s-master --tags cluster:$CLUSTER_NAME --tags env:$ENVIRONMENT --type $MASTER_NODE_TYPE > master-$N.$CLUSTER_NAME.k.json; do
    echo retrying...
    sleep 1
  done
  cat <<EOF
- address: $(jq -r '.[].ipv4[0]' < master-$N.$CLUSTER_NAME.k.json)
  port: "22"
  internal_address: $(jq -r '.[].ipv4[1]' < master-$N.$CLUSTER_NAME.k.json)
  role:
  - controlplane
  - worker
  - etcd
  hostname_override: master-$N
  user: root
  docker_socket: /var/run/docker.sock
  ssh_key: ""
  ssh_key_path: ~/src/minespray/hufr
  ssh_cert: ""
  ssh_cert_path: ""
  labels: {}
  taints: []
EOF
done

for N in $(seq $WORKER_COUNT); do
  while ! lc --label worker-$N.$CLUSTER_NAME.k --tags k8s --tags k8s-worker --tags cluster:$CLUSTER_NAME --tags env:$ENVIRONMENT --type $WORKER_NODE_TYPE > worker-$N.$CLUSTER_NAME.k.json; do
    echo retrying...
    sleep 1
  done
  cat <<EOF
- address: $(jq -r '.[].ipv4[0]' < worker-$N.$CLUSTER_NAME.k.json)
  port: "22"
  internal_address: $(jq -r '.[].ipv4[1]' < worker-$N.$CLUSTER_NAME.k.json)
  role:
  - worker
  - etcd
  hostname_override: worker-$N
  user: root
  docker_socket: /var/run/docker.sock
  ssh_key: ""
  ssh_key_path: ~/src/minespray/hufr
  ssh_cert: ""
  ssh_cert_path: ""
  labels: {}
  taints: []
EOF
done
