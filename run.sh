#!/bin/bash

# Project to use cloud run
PROJECT_ID='cloud-run-script-19841'
PROJECT_NAME='Some Project'

# Used for image name and service name
APP_NAME='my-app'

# "Cloud run" settings (more on "gcloud beta run deploy --help")
REGION='asia-northeast1'
PLATFORM='managed'
DEPLOY_OPTS=(
  --flags-file=set-env-vars.yml
  --allow-unauthenticated
  --memory=256Mi   # default 256Mi
  --concurrency=10 # default 80
  --timeout=1m     # default 5m
)

# Specify local image name and how to build it
LOCAL_IMAGE_NAME='cloud-run-script_app'
LOCAL_BUILD_CMD='docker-compose build app'

. run-main.sh
