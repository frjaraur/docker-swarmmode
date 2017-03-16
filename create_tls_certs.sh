#!/bin/bash -x

PASSPHRASE=$1

ip=$2

iphostonly=$3

nodename=$4

TMPSHARED="/tmp_deploying_stage"

## Generate TLS certs

echo "Enabling TLS on Docker Engines"

mkdir -p /etc/docker/certs.d && chmod 750 /etc/docker/certs.d
mkdir /root/.docker && chmod 750 /root/.docker

echo "Certificates Authority"

if [ ! -f ${TMPSHARED}/ca.pem ]
then
	## Generate CA
	docker run --rm --net=none -e SERVERNAME=${nodename} \
	-e SERVERIPS="${ip}},0.0.0.0" -e PASSPHRASE="${PASSPHRASE}"  \
	-e CLIENTNAME="${nodename}" -v /etc/docker/certs.d:/certs \
	frjaraur/docker-simple-tlscerts generate_CA

	cp -p /etc/docker/certs.d/ca.pem ${TMPSHARED}/ca.pem && \
	cp -p /etc/docker/certs.d/ca-key.pem ${TMPSHARED}/ca-key.pem

else
	cp ${TMPSHARED}/ca.pem /etc/docker/certs.d/ca.pem && \
	cp ${TMPSHARED}/ca-key.pem /etc/docker/certs.d/ca-key.pem && \
	chown root:root /etc/docker/certs.d/ca.pem && \
	chmod -v 0444 /etc/docker/certs.d/ca.pem

fi

echo "Certificates for Server"

	## Generate Server Keys
	docker run --rm --net=none -e SERVERNAME=${nodename} \
	-e SERVERIPS="${ip},${iphostonly},0.0.0.0,127.0.0.1" -e PASSPHRASE="${PASSPHRASE}"  \
	-e CLIENTNAME="${nodename}" -v /etc/docker/certs.d:/certs \
	frjaraur/docker-simple-tlscerts generate_serverkeys

echo "Certificates for Client"


	## Generate Client Keys
	docker run --rm --net=none -e SERVERNAME=${nodename} \
	-e SERVERIPS="${ip},0.0.0.0,127.0.0.1" -e PASSPHRASE="${PASSPHRASE}"  \
	-e CLIENTNAME="${nodename}" -v /etc/docker/certs.d:/certs \
	frjaraur/docker-simple-tlscerts generate_clientkeys

	chmod -v 0400 /etc/docker/certs.d/*key.pem
	chmod -v 0444 /etc/docker/certs.d/ca.pem /etc/docker/certs.d/*cert.pem

	mv /etc/docker/certs.d/server-key.pem /etc/docker/certs.d/key.pem
	mv /etc/docker/certs.d/server-cert.pem /etc/docker/certs.d/cert.pem

	mv /etc/docker/certs.d/client-key.pem /root/.docker/key.pem
	mv /etc/docker/certs.d/client-cert.pem /root/.docker/cert.pem
	cp -p /etc/docker/certs.d/ca.pem /root/.docker/ca.pem

## Configure Docker Engines with Swarm. TLS and KeyValue Store Information
#echo "DOCKER_TLS_VERIFY=1" >> /etc/default/docker
#echo "DOCKER_CERT_PATH=\"/etc/docker/certs.d\"" >> /etc/default/docker
DOCKER_OPTS="-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2376  \
	--tlsverify  \
	--tlscacert=/etc/docker/certs.d/ca.pem \
	--tlscert=/etc/docker/certs.d/cert.pem \
	--tlskey=/etc/docker/certs.d/key.pem"


cat /lib/systemd/system/docker.service |sed "s|ExecStart=.*|ExecStart=/usr/bin/dockerd ${DOCKER_OPTS}|g" >> /etc/systemd/system/docker.service

cp -p /etc/docker/certs.d/ca.pem /usr/share/ca-certificates/ca.pem

update-ca-certificates

service docker restart