#!/bin/bash -x

SWARMIP=$1

SWARMROLE=$2

SWARMMASTER_IP=$3

VERSION=$4

DOCKERVERSION=${VERSION:=get}


case ${DOCKERVERSION} in
  current)
    DOCKERVERSION="get"
  ;;

  experimental)
    DOCKERVERSION="experimental"
  ;;

  testing)
    DOCKERVERSION="test"
  ;;
  
esac

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


USER="vagrant"
[ $(grep -c "${USER}" /etc/passwd) -ne 1 ] && USER="ubuntu"


if ! dpkg -l docker >/dev/null 2>&1
then
  #Install Engine (This way, we can reprovision)
  InfoMessage "Installing Docker"
  apt-get install -qq curl \
  && curl -sSk https://${DOCKERVERSION}.docker.com | sh \
  && usermod -aG docker ${USER}
fi

#DOCKER_DAEMON="docker -H ${SWARMIP}:2375"
InfoMessage "SWARM MODE ROLE [${SWARMROLE}]"
case ${SWARMROLE} in
  manager)
    [ ! -f ${TMPSHARED}/manager.token ] && InfoMessage "Initiating Swarm Cluster" \
    && docker swarm init --advertise-addr ${SWARMIP} --listen-addr  ${SWARMIP} \
    && docker swarm join-token manager -q > ${TMPSHARED}/manager.token \
    && docker swarm join-token worker -q > ${TMPSHARED}/worker.token \
    && exit

    [ -f ${TMPSHARED}/manager.token ] && InfoMessage "Joining Swarm Cluster" \
    && docker swarm join ${SWARMMASTER_IP}:2377 --advertise-addr ${SWARMIP}  --listen-addr  ${SWARMIP} \
    --token $(cat ${TMPSHARED}/manager.token)
  ;;

  worker)
    docker swarm join ${SWARMMASTER_IP}:2377 --advertise-addr ${SWARMIP}  --listen-addr  ${SWARMIP} \
    --token $(cat ${TMPSHARED}/worker.token)

  ;;

esac
