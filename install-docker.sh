#!/bin/bash

inst() {
  set -e

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io
}

inst > /tmp/install-docker.log 2>&1 &

echo Installing Docker...
