#/bin/bash

image=$(docker ps -qa --filter "ancestor=counterparty")
docker exec -ti "$image" bash
