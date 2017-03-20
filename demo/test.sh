docker service rm cserver cagent visage
docker network rm collectd

docker network create -d overlay collectd

docker service create --name cserver --network collectd \
  --env PLUGINS=load \
  --label service_name="docker-statistics" \
  --constraint 'node.hostname == node1' \
  --mount type=volume,source=COLLECTD_SERVER,target=/DATA,volume-driver=local \
  frjaraur/docker-collectd server

docker service create --name cagent --mode global --network collectd --env SERVER=cserver \
  --env PLUGINS=docker \
  --label service_name="docker-statistics" \
  --mount type=volume,source=COLLECTD_AGENT,target=/DATA,volume-driver=local \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  frjaraur/docker-collectd agent

docker service create --name visage --publish 8080:9292 --env RRDDIR=/DATA/collectd/rrd \
  --label service_name="docker-statistics" \
  --constraint 'node.hostname == node1' \
  --mount type=volume,source=COLLECTD_SERVER,target=/DATA,volume-driver=local \
  fr3nd/visage

#docker run   -it   --rm   --volumes-from cserver   -e RRDDIR=/DATA/collectd/rrd   -p 9292:9292   fr3nd/visage
