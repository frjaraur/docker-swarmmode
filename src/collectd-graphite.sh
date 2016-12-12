docker network create -d overlay collectd

echo "... Starting Collectd Agent ..."
docker service create --name cagent --mode global \
--network collectd \
--env GRAPHITE_SERVER=graphite \
--env PLUGINS="docker write_graphite" \
--label service_name="docker-statistics" \
--mount type=volume,source=COLLECTD_AGENT,target=/DATA,volume-driver=local \
--mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
--mount type=bind,src=/etc/timezone,dst=/etc/timezone \
--mount type=bind,src=/etc/localtime,dst=/etc/localtime \
frjaraur/docker-collectd agent

echo "... Starting Graphite ..."
#docker service create --name graphite \
#--network collectd \
#--publish 8080:80 --env RRDDIR=/DATA/collectd/rrd \
#--label service_name="Graphite" \
#--mount type=volume,source=GRAPHITE,target=/var/lib/graphite/storage/whisper,volume-driver=local \
#frjaraur/graphite start

docker run -d -p 8080:80 --name graphite --env RRDDIR=/DATA/collectd/rrd -v GRAPHITE:/var/lib/graphite/storage/whisper frjaraur/graphite start
