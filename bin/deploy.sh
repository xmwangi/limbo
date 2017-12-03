#!/bin/bash -ve

# Designed to be used from one's laptop and from Travis.  The
# existence of TRAVIS_BRANCH is used to test where it's running.
#
# In both cases, the standard AWS_ environment variables need to be
# defined to provide the AWS credentials for accessing ECR and ECS.
# Also, BOTNAME must be defined, which determines both the name of the
# image in the Docker registry and the name of the service in ECS.
#
# When running on a laptop, `git symbolic-ref --short HEAD` is used in
# place of TRAVIS_BRANCH to determine what branch is being built (so
# it must be run from inside the repo).  Further, MASTER_SLACK_TOKEN
# or WIP_SLACK_TOKEN must be defined (based on whether this is master
# or WIP deploy).

if [ $# -ne 1 ] || ([ "$1" != "up" ] && [ "$1" != "down" ]); then
  echo "Usage: $0 up|down"
  exit 1
fi

if [ "$TRAVIS_BRANCH" != "" ]; then
  if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    echo Skipping travis_deploy for pull request
    exit 0
  fi
  export THE_BRANCH=$TRAVIS_BRANCH
else
  export THE_BRANCH=`git symbolic-ref --short HEAD`
fi

export TYPE=`expr "$THE_BRANCH" : ".*\(wip$\)"`
if [ "$TYPE" != "wip" ]; then
  export TYPE=`expr "$THE_BRANCH" : ".*\(master$\)"`
  if [ "$TYPE" != "master" ]; then
    echo Branch name does not end in "wip" or "master": skip deploy
    exit 0
  fi
fi

if [ "$SLACK_TOKEN" = "" ]; then
  if [ "$TYPE" = "master" ]; then
    export SLACK_TOKEN=$MASTER_SLACK_TOKEN
  else
    export SLACK_TOKEN=$WIP_SLACK_TOKEN
  fi
fi
if [ "$SLACK_TOKEN" = "" ]; then
  echo Missing ${TYPE}_SLACK_TOKEN
  exit 1
fi

export IMAGE_THIS_BUILD=560921689673.dkr.ecr.us-east-1.amazonaws.com/tim77/$BOTNAME:$TYPE

if [ "$1" = "up" ]; then
  bin/ecr_push.sh
  docker-compose -f cmds.yml run \
    ecs compose --region us-east-1 -c limbo \
      --file docker-compose.yml --project-name $BOTNAME-$TYPE \
      service up
else
  docker-compose -f cmds.yml run \
    ecs compose --region us-east-1 -c limbo \
      --file docker-compose.yml --project-name $BOTNAME-$TYPE \
      service rm
fi
