#!/bin/bash -ve

# Designed to be used from one's laptop and from Travis.  The
# existence of TRAVIS_BRANCH is used to test where it's running.
#
# In both cases, the standard AWS_ environment variables need to be
# defined to provide the AWS credentials for accessing ECR and ECS.
#
# When running on a laptop, `git symbolic-ref --short HEAD` is used in
# place of TRAVIS_BRANCH to determine what branch is being built.
# Further, MASTER_SLACK_TOKEN and WIP_SLACK_TOKEN must be defined.


if [ "$TRAVIS_BRANCH" != "" ]; then
  if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    echo Skipping after_test for pull request
    exit 0
  fi
  export THE_BRANCH=$TRAVIS_BRANCH
else
  export THE_BRANCH=`git symbolic-ref --short HEAD`
fi

export IS_WIP=`expr "$THE_BRANCH" : ".*-\(wip$\)"`
export IS_MASTER=`expr "$THE_BRANCH" : ".*-\(master$\)"`
export BOTNAME=`expr "$THE_BRANCH" : "\(.*\)-[a-z]*$"`

if [ "$IS_WIP" = "wip" ]; then
  export TYPE="wip"
elif [ "$IS_MASTER" = "master" ]; then
  export TYPE="master"
else
  echo Skipping after_test for non-wip/master branch
  exit 0
fi

if [ "$MASTER_SLACK_TOKEN" = "" ] && [ "$WIP_SLACK_TOKEN" = "" ]; then
  openssl aes-256-cbc \
    -K $encrypted_a8cf50fc24e7_key -iv $encrypted_a8cf50fc24e7_iv \
    -in secrets/${BOTNAME}.sh.enc -out secrets.sh -d
  set +v # Don't reveal secrets to output log
  source ./secrets.sh
  set -v
fi

if [ "$TYPE" = "master" ]; then
  export SLACK_TOKEN=$MASTER_SLACK_TOKEN
else
  export SLACK_TOKEN=$WIP_SLACK_TOKEN
fi
if [ "$SLACK_TOKEN" = "" ]; then
  echo Missing ${TYPE}_SLACK_TOKEN
  exit 1
fi

export IMAGE_THIS_BUILD=$BOTNAME:$TYPE

bin/ecr_push.sh
bin/ecs_deploy.sh $THE_BRANCH
