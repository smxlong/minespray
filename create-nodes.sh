#!/bin/bash

set -e

MASTER_COUNT=2
MASTER_NODE_TYPE=g6-standard-1

WORKER_COUNT=3
WORKER_NODE_TYPE=g6-standard-2

CLUSTER_NAME=dev-minecraft
ENVIRONMENT=dev

lc() {
  linode-cli linodes create --root_pass bXuK86wKv4JXGP0gE5kbGYlHZiSG9c2w/MWH9jzd5Cg= --authorized_keys "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA4A+ki6PaU+SIYpkx5Cm6LtA0Lr05qGstQp2bySh9YU1wodRmcolRIbiaPzfalURrNcFjFfnWW2SuoyF4U3XeA7LCfrnN7T2d0Kp9facA4rSkSW7tSdZIgyo9trRK2d+lgGrr2Hs8wYAaU4D61ptksdVWfgpuPDXDdk90VWVAhP2FeB+EFB7CZxtw7p6TN4YC2GNpBQIPfvGvgnl/9WyrHQU2hMIWMQ9+2XmwMBF9iwpbCAkLhdNUNYrDI6sig9cLIAClvJLCgmHruSy1Ns2FjYbt9avpNulRZu6yBApJGzbF8thBYE0fgOB3gsHLqk+gjR7hGC6ZF68cyUfQIsjghw== rsa-key-20191220" --private_ip true $*
}

for N in $(seq $MASTER_COUNT); do
  lc --label master-$N.$CLUSTER_NAME.k --tags k8s --tags k8s-master --tags cluster:$CLUSTER_NAME --tags env:$ENVIRONMENT --type $MASTER_NODE_TYPE
done

for N in $(seq $WORKER_COUNT); do
  lc --label worker-$N.$CLUSTER_NAME.k --tags k8s --tags k8s-worker --tags cluster:$CLUSTER_NAME --tags env:$ENVIRONMENT --type $WORKER_NODE_TYPE
done
