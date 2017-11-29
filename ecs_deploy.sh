#!/bin/sh

if [ "$TRAVIS_BRANCH" != "rstata-wip" ]; then
  exit 0
fi

docker-compose -f cmds.yml run \
  ecs compose --region us-east-1 -c limbo --file docker-compose.yml \
    service up
