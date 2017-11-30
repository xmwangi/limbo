#!/bin/bash -ve

if [$# -ne 1]; then
  echo "Usage: $0 project-name"
fi

docker-compose -f cmds.yml run \
  ecs compose --region us-east-1 -c limbo \
    --file docker-compose.yml --project-name $1 \
    service up
