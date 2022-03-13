#!/bin/bash
composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

if [ "$2" == "dev" ]; then
  printf "\nRunning Client Registry SanteMPI package in DEV mode\n"
  santeMpiDevComposeParam="-c ${composeFilePath}/docker-compose.dev.yml"
else
  printf "\nRunning Client Registry SanteMPI package in PROD mode\n"
  santeMpiDevComposeParam=""
fi

if [ "$1" == "init" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml $santeMpiDevComposeParam instant
elif [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml $santeMpiDevComposeParam instant
elif [ "$1" == "down" ]; then
  docker service scale instant_santedb-postgres=0 instant_santedb-mpi=0 instant_santedb-www=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_santedb-postgres instant_santedb-mpi instant_santedb-www

  echo "Sleep 10 Seconds to allow services to shut down before deleting volumes"
  sleep 10

  docker volume rm instant_santedb-data instant_santedb-postgres-data

  if [ $statefulNodes == "cluster" ]; then
    echo "Volumes are only deleted on the host on which the command is run. Mongo volumes on other nodes are not deleted"
  fi
else
  echo "Valid options are: init, up, down, or destroy"
fi
