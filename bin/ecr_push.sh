#!/bin/sh

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo Skipping push for pull request
  exit 0
fi

if [ "$TRAVIS_BRANCH" != "rstata-wip" ]; then
  echo Skipping push for non-wip branch
  exit 0
fi

## Acrobatics here works around both awscli and MacOS problems I've
## been encountering

docker-compose -f cmds.yml run aws ecr get-login \
                    --region us-east-1 --no-include-email > limbo-tmp

cat limbo-tmp | sed 's/docker login -u AWS -p \([^ ]*\) .*/\1/' \
 | docker login -u AWS --password-stdin \
              560921689673.dkr.ecr.us-east-1.amazonaws.com

rm limbo-tmp

docker tag tim77/limbo:latest \
  560921689673.dkr.ecr.us-east-1.amazonaws.com/tim77-rstata/limbo:latest

docker push \
  560921689673.dkr.ecr.us-east-1.amazonaws.com/tim77-rstata/limbo:latest
