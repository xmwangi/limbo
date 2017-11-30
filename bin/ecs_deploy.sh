#!/bin/sh

docker-compose -f cmds.yml run \
  ecs compose --region us-east-1 -c limbo \
    --file docker-compose.yml --project-name $BOTNAME \
    service up
