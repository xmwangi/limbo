#!/bin/sh

if [ "$TRAVIS_BRANCH" != "rstata-wip" ]; then
  exit 0
fi

eval $(docker-compose -f cmds.yml run aws ecr get-login --region us-east-1)

docker tag tim77/limbo:latest \
  560921689673.dkr.ecr.us-east-1.amazonaws.com/tim77-rstata/limbo:latest

docker push \
  560921689673.dkr.ecr.us-east-1.amazonaws.com/tim77-rstata/limbo:latest
