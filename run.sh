#!/bin/bash

function Main() {
  local RUN_CONFIG="${RUN_CONFIG:-run-config.sh}"
  if [ ! -e "${RUN_CONFIG}" ]; then
    echo ":: Config file (${RUN_CONFIG}) not found."
    exit 1;
  fi
  source "${RUN_CONFIG}"
  local GCR_IMAGE_NAME="gcr.io/${PROJECT_ID}/${APP_NAME}"

  case $1 in
    show)
      case $2 in
        project)
          echo ':: web dashboard url'
          echo "https://console.cloud.google.com/home/dashboard?project=${PROJECT_ID}"
          echo
          echo ':: projects describe'
          gcloud projects describe "${PROJECT_ID}"
          echo
          echo ':: billing describe'
          gcloud beta billing projects describe "${PROJECT_ID}"
          echo
          echo ':: services list'
          gcloud --project="${PROJECT_ID}" services list
          echo
        ;;

        resources)
          echo ':: cloud run'
          gcloud --project="${PROJECT_ID}" beta run services list --platform="${PLATFORM}"
          echo
          echo ':: container image'
          gcloud container images list-tags "${GCR_IMAGE_NAME}"
          echo
          echo ':: logs'
          gcloud --project="${PROJECT_ID}" logging logs list
        ;;

        run)
          gcloud --project="${PROJECT_ID}" beta run services list --platform="${PLATFORM}" --format=yaml
        ;;

        url)
          gcloud --project="${PROJECT_ID}" beta run services list --platform=managed --format=json \
            | jq -r '.[] | .status.url'
        ;;

        *) echo ":: Command (${@}) not found" ;;
      esac
    ;;

    deploy)
      docker tag "${IMAGE_NAME}" "${GCR_IMAGE_NAME}" &&\
      docker push "${GCR_IMAGE_NAME}" &&\
      gcloud beta run deploy "${APP_NAME}" \
        --project="${PROJECT_ID}" \
        --region="${REGION}" \
        --platform="${PLATFORM}" \
        --image="${GCR_IMAGE_NAME}" \
        "${DEPLOY_OPTS[@]}"
    ;;

    logs)
      gcloud --project "${PROJECT_ID}" logging read \
        "logName:stdout OR logName:stderr AND resource.labels.service_name=${APP_NAME}" --format=json \
        | jq -r 'reverse | .[] | "\(.timestamp) \(.textPayload)"'
    ;;

    # Create gcloud project with builling account
    setup-project)
      ACCOUNT_ID=$(gcloud beta billing accounts list --filter='open=true' --format=json | jq -r '.[] | .name')
      if test -z "${ACCOUNT_ID}"; then
        echo ":: setup-project failed (No available billing account)"; exit 1
      fi

      echo ":: Use billing account (${ACCOUNT_ID}) to setup project"
      echo ":: Creating project..."
      gcloud projects create "${PROJECT_ID}" --name="${PROJECT_NAME}" --no-enable-cloud-apis

      echo ":: Linking billing account..."
      gcloud beta billing projects link "${PROJECT_ID}" --billing-account="${ACCOUNT_ID}"
    ;;

    cleanup-project)
      gcloud projects delete "${PROJECT_ID}"
    ;;

    # Setup "cloud run" for existing project
    setup-run)
      # By "dependency", these automatically enable services on the right
      echo ":: Enabling google services (containerregistry, run) ..."
      gcloud --project="${PROJECT_ID}" services enable containerregistry.googleapis.com # pubsub, storage-api
      gcloud --project="${PROJECT_ID}" services enable run.googleapis.com # logging, source, storage-component

      # Let "docker push" access to gcloud
      echo ":: Configuring docker ..."
      gcloud auth configure-docker
    ;;

    cleanup-run)
      echo ':: cloud run'
      gcloud beta run services delete "${APP_NAME}" \
        --project="${PROJECT_ID}" --platform="${PLATFORM}" --region="${REGION}" --quiet
      echo

      echo ':: image'
      gcloud container images list-tags "${GCR_IMAGE_NAME}" --format='get(digest)' \
        | xargs -I _arg_ gcloud container images delete "${GCR_IMAGE_NAME}@_arg_" --quiet --force-delete-tags
      echo
    ;;

    # Delete non-latest images
    prune-images)
      gcloud container images list-tags "${GCR_IMAGE_NAME}" --filter='tags[0]!=latest' --format='get(digest)' \
        | xargs -I _arg_ gcloud container images delete "${GCR_IMAGE_NAME}@_arg_" --quiet --force-delete-tags
    ;;

    *) echo ":: Command (${@}) not found" ;;
  esac
}

Main "${@}"
