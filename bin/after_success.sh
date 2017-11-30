#!/bin/sh

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo Skipping after_success for pull request
  exit 0
fi

if [ "$TRAVIS_BRANCH" != "rstata-wip" ]; then
  echo Skipping after_success for non-wip branch
  exit 0
fi

openssl aes-256-cbc \
  -K $encrypted_887fc2baaf3c_key -iv $encrypted_887fc2baaf3c_iv \
  -in secrets/rstata-env.sh.enc -out env.sh -d

source secrets.sh

bin/ecr_push.sh
bin/ecs_deploy.sh
