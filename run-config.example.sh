#/bin/bash

# Project to use cloud run
PROJECT_ID='my-project-95fd35'
PROJECT_NAME='My Project'

# Used for image name and service name
APP_NAME='my-app'

# "Cloud run" settings (more on "gcloud beta run deploy --help")
REGION='asia-northeast1'
PLATFORM='managed'
DEPLOY_OPTS=(
  --allow-unauthenticated
  --memory=256Mi   # default 256Mi
  --concurrency=10 # default 80
  --timeout=1m     # default 5m
)

# Specify local image name
IMAGE_NAME='my-image'
