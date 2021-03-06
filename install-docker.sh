#!/bin/bash

for NODE_IP in $(linode-cli linodes list --tags k8s --json | jq -r '.[].ipv4[0]'); do
  scp -o StrictHostKeychecking=no -i hufr install-docker-script.sh $NODE_IP:/root
  ssh -o StrictHostKeychecking=no -i hufr $NODE_IP /root/install-docker-script.sh
done
