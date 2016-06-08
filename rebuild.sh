#!/bin/bash
#Script to rebuild the docker image from Dockerfile.
cd /docker/files/pentaho-ba
docker stop pentaho-ba; docker rm pentaho-ba; docker rmi pentaho-ba
docker build --no-cache -t pentaho-ba .
