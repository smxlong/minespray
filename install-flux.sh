#!/bin/bash

helm3 repo add fluxcd https://charts.fluxcd.io
helm3 repo update
kubectl create namespace flux --dry-run=client -o yaml | kubectl apply -f -
helm3 upgrade -i flux fluxcd/flux \
  --set git.url=git@github.com:smxlong/minespray.git \
  --set git.path=gitops \
  --set git.pollInterval=15s \
  --set git.readonly=true \
  --set logFormat=json \
  --set syncGarbageCollection.enabled=true \
  --set sync.state=secret \
  --set sync.interval=15s \
  --namespace flux

helm3 upgrade -i helm-operator fluxcd/helm-operator \
  --set git.pollInterval=15s \
  --set git.ssh.secretName=flux-git-deploy \
  --set logFormat=json \
  --set helm.versions=v3 \
  --set chartsSyncInterval=15s \
  --namespace flux
