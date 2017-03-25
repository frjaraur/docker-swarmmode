#!/bin/bash

#curl -Ls https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

#chmod +x /usr/local/bin/docker-compose

sudo apt-get install -qq python-pip

sudo -H LC_ALL=C pip install docker-compose

