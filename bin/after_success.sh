#!/bin/sh -ve

export IS_WIP=`expr "$TRAVIS_BRANCH" : ".*-\(wip$\)"`
export STUDENT=`expr "$TRAVIS_BRANCH" : "\(.*\)-[a-z]*$"`

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo Skipping after_success for pull request
  exit 0
fi

if [ "$IS_WIP" != "wip" ]; then
  echo Skipping after_success for non-wip branch
  exit 0
fi

echo Student: $STUDENT

openssl aes-256-cbc \
  -K $encrypted_887fc2baaf3c_key -iv $encrypted_887fc2baaf3c_iv \
  -in secrets/${STUDENT}-env.sh.enc -out secrets.sh -d

source secrets.sh

bin/ecr_push.sh
bin/ecs_deploy.sh $TRAVIS_BRANCH
