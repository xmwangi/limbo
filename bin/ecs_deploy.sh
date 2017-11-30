#!/bin/sh

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo Skipping deploy for pull request
  exit 0
fi

if [ "$TRAVIS_BRANCH" != "rstata-wip" ]; then
  echo Skipping deploy for non-wip branch
  exit 0
fi

docker-compose -f cmds.yml run \
  ecs compose --region us-east-1 -c limbo \
    --file docker-compose.yml --project-name $BOTNAME \
    service up
