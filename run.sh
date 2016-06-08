#!/bin/bash
docker stop pentaho-ba
docker rm pentaho-ba
docker run -d --name pentaho-ba -p 8080:8080 -e Tier=TEST -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db:pentaho-db -v /docker/mounts/pentaho-ba/opt/pentaho:/opt/pentaho pentaho-ba &