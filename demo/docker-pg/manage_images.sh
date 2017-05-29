#!/bin/bash
docker login registry.gitlab.com
docker pull registry.gitlab.com/codegazers/docker-pg-demo:docker-pg
docker pull registry.gitlab.com/codegazers/docker-pg-demo:simplestapp
docker pull registry.gitlab.com/codegazers/docker-pg-demo:frontend
docker pull registry.gitlab.com/codegazers/docker-pg-demo:simplestlb

docker tag registry.gitlab.com/codegazers/docker-pg-demo:frontend localhost:5000/docker-pg-demo:frontend
docker tag registry.gitlab.com/codegazers/docker-pg-demo:docker-pg localhost:5000/docker-pg-demo:docker-pg
docker tag registry.gitlab.com/codegazers/docker-pg-demo:simplestapp localhost:5000/docker-pg-demo:simplestapp
docker tag registry.gitlab.com/codegazers/docker-pg-demo:simplestlb localhost:5000/docker-pg-demo:simplestlb


docker push localhost:5000/docker-pg-demo:frontend
docker push localhost:5000/docker-pg-demo:docker-pg
docker push localhost:5000/docker-pg-demo:simplestapp
docker push localhost:5000/docker-pg-demo:simplestlb


docker pull  manomarks/visualizer
docker tag manomarks/visualizer:latest localhost:5000/manomarks/visualizer:latest
docker push localhost:5000/manomarks/visualizer:latest

