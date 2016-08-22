#!/bin/sh
apt-get install -qq unzip collectd collectd-utils

wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py && python get-pip.py

cd /usr/share/collectd/ && wget --no-check-certificate https://github.com/lebauce/docker-collectd-plugin/archive/master.zip && \
unzip master.zip -d /usr/share/collectd/ && mv /usr/share/collectd/docker-collectd-plugin-master /usr/share/collectd/docker-collectd-plugin && \
cd /usr/share/collectd/docker-collectd-plugin && pip install -r requirements.txt


awk '/FSType tmpfs/ { printf "%s\n\tFSType vboxsf\n",$0 }' /etc/collectd/collectd.conf >/etc/collectd/collectd.conf. && mv /etc/collectd/collectd.conf. /etc/collectd/collectd.conf



echo "TypesDB \"/usr/share/collectd/docker-collectd-plugin/dockerplugin.db\"
LoadPlugin python

<Plugin python>
  ModulePath \"/usr/share/collectd/docker-collectd-plugin\"
  Import \"dockerplugin\"

  <Module dockerplugin>
    BaseURL \"unix://var/run/docker.sock\"
    Timeout 3
  </Module>
</Plugin>" >/etc/collectd/collectd.conf.d/dockerplugin.conf

service collectd restart
