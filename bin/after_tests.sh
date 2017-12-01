#!/bin/bash -ve

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo Skipping after_test for pull request
  exit 0
fi

export IS_WIP=`expr "$TRAVIS_BRANCH" : ".*-\(wip$\)"`
export IS_MASTER=`expr "$TRAVIS_BRANCH" : ".*-\(wip$\)"`
export BOTNAME=`expr "$TRAVIS_BRANCH" : "\(.*\)-[a-z]*$"`

if [ "$IS_WIP" = "wip" ]; then
  export TYPE="wip"
elif [ "$IS_MASTER" = "master" ]; then
  export TYPE="master"
else
  echo Skipping after_test for non-wip/master branch
  exit 0
fi

openssl aes-256-cbc \
  -K $encrypted_a8cf50fc24e7_key -iv $encrypted_a8cf50fc24e7_iv \
  -in secrets/${BOTNAME}.sh.enc -out secrets.sh -d

source ./secrets.sh
if [ "$TYPE" = "master" ]; then
  export SLACK_TOKEN=$MASTER_SLACK_TOKEN
else
  export SLACK_TOKEN=$WIP_SLACK_TOKEN
fi

bin/ecr_push.sh
bin/ecs_deploy.sh $TRAVIS_BRANCH
