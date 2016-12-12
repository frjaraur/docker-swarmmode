#!/bin/sh

CASSANDRA_NODES=${CASSANDRA_NODES:=3}

docker network rm cassandra 

docker network create -d overlay cassandra

#Master Node
I="_PUBLISHED"
docker service create \
--name "cassandra${I}" \
--network cassandra \
--publish 7000:7000 \
--label service_name="cassandra${I}" \
--mount type=volume,source=cassandra${I},target=/var/lib/cassandra,volume-driver=local \
cassandra

docker service create \
--name "cassandra" \
--network cassandra \
--replicas 3 \
--label service_name="cassandra" \
--mount type=volume,target=/var/lib/cassandra,volume-driver=local \
cassandra

