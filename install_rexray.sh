#!/bin/bash
curl -sSL https://dl.bintray.com/emccode/rexray/install | sh
sudo mv /tmp/rexray.config.yml /etc/rexray/config.yml
rexray stop 
rexray start

