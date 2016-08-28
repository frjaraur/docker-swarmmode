#!/bin/bash

SWARMIP=$1

SWARMROLE=$2

SWARMMASTER_IP=$3
#SHARED Between Nodes..
TMPSHARED="/tmp_deploying_stage"
#Docker Multi Daemon

# DEFAULTS

DOCKER_ROOTDIR="${DOCKER_ROOTDIR:=/var/lib/docker}"
DOCKER_RUNDIR="${DOCKER_RUNDIR:=/var/run}"
DOCKER_CONFIGDIR="${DOCKER_CONFIGDIR:=/etc/docker}"
DOCKER_LOGDIR="${DOCKER_LOGDIR:=/var/log/docker}"

ErrorMessage(){
  echo "$(date +%Y/%m/%d-%H:%M:%S) ERROR: $*"
  exit 1
}

InfoMessage(){
  echo "$(date +%Y/%m/%d-%H:%M:%S) INFO: $*"
}


if ! dpkg -l docker >/dev/null 2>&1
then
  #Install Engine (This way, we can reprovision)
  InfoMessage "Installing Docker"
  apt-get install -qq curl \
  && curl -sSL https://get.docker.com/ | sh \
  && curl -fsSL https://get.docker.com/gpg | sudo apt-key add - \
  && usermod -aG docker vagrant
fi

#DOCKER_DAEMON="docker -H ${SWARMIP}:2375"
InfoMessage "SWARM MODE ROLE [${SWARMROLE}]"
case ${SWARMROLE} in
  manager)
    [ ! -f ${TMPSHARED}/manager.token ] && InfoMessage "Initiating Swarm Cluster" \
    && docker swarm init --advertise-addr ${SWARMIP} --listen-addr eth1 \
    && docker swarm join-token manager -q > ${TMPSHARED}/manager.token \
    && docker swarm join-token worker -q > ${TMPSHARED}/worker.token \
    && exit

    [ -f ${TMPSHARED}/manager.token ] && InfoMessage "Joining Swarm Cluster" \
    && docker swarm join ${SWARMMASTER_IP}:2377 --advertise-addr ${SWARMIP}  --listen-addr eth1 \
    --token $(cat ${TMPSHARED}/manager.token)
  ;;

  worker)
    docker swarm join ${SWARMMASTER_IP}:2377 --advertise-addr ${SWARMIP}  --listen-addr eth1 \
    --token $(cat ${TMPSHARED}/worker.token)

  ;;

esac
