#!/bin/bash
docker stack deploy -c registry.yml registry
docker stack deploy -c docker-pg.yml demo
docker stack deploy -c visualizer.yml visualizer
