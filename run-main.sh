IMAGE_NAME="gcr.io/${PROJECT_ID}/${APP_NAME}"

case $1 in
  show)
    case $2 in
      me)
        gcloud config list
      ;;
      project)
        echo ':: projects describe'
        gcloud projects describe "${PROJECT_ID}"
        echo
        echo ':: billing describe'
        gcloud beta billing projects describe "${PROJECT_ID}"
        echo
        echo ':: services list'
        gcloud --project="${PROJECT_ID}" services list
      ;;
      resources)
        echo ':: cloud run'
        gcloud --project="${PROJECT_ID}" beta run services list --platform="${PLATFORM}"
        echo
        echo ':: container image'
        gcloud container images list-tags "${IMAGE_NAME}"
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
    eval "${LOCAL_BUILD_CMD}" &&\
    docker tag "${LOCAL_IMAGE_NAME}" "${IMAGE_NAME}" &&\
    docker push "${IMAGE_NAME}" &&\
    gcloud beta run deploy "${APP_NAME}" \
      --project="${PROJECT_ID}" \
      --region="${REGION}" \
      --platform="${PLATFORM}" \
      --image="${IMAGE_NAME}" \
      "${DEPLOY_OPTS[@]}"
  ;;
  deploy-update)
    gcloud beta run deploy "${APP_NAME}" \
      --project="${PROJECT_ID}" \
      --region="${REGION}" \
      --platform="${PLATFORM}" \
      --image="${IMAGE_NAME}" \
      "${DEPLOY_OPTS[@]}"
  ;;

  logs)
    shift
    case $1 in
      request)
        gcloud --project "${PROJECT_ID}" logging read \
        "logName:run.googleapis.com%2Frequest AND resource.labels.service_name=${APP_NAME}" --format=json \
          | jq -r 'reverse | .[] |
            "\(.timestamp)\t\(.httpRequest.requestMethod)\t\(.httpRequest.requestUrl | capture("https://[^/]*(?<path>.*)") | .path)\t\(.httpRequest.status)\t\(.httpRequest.responseSize)\t\(.httpRequest.latency | rtrimstr("s") | .[0:6] | tonumber * 1000 )ms"'
      ;;
      # e.g. filter logName:varlog
      filter)
        shift
        gcloud --project "${PROJECT_ID}" logging read "${1} AND resource.labels.service_name=${APP_NAME}" --format=json \
          | jq -r 'reverse | .[] | "\(.timestamp) \(.textPayload)"'
      ;;
      jq)
        shift
        gcloud --project "${PROJECT_ID}" logging read \
          "logName:run.googleapis.com AND resource.labels.service_name=${APP_NAME}" --format=json \
          | jq "${@}"
      ;;
      *)
        gcloud --project "${PROJECT_ID}" logging read \
          "logName:stdout OR logName:stderr AND resource.labels.service_name=${APP_NAME}" --format=json \
          | jq -r 'reverse | .[] | "\(.timestamp) \(.textPayload)"'
      ;;
    esac
  ;;

  setup-project)
    ACCOUNT_ID=$(gcloud beta billing accounts list --filter='open=true' --format=json | jq -r '.[] | .name')
    if test -z "${ACCOUNT_ID}"; then
      echo ":: Failed to setup [No available billing account]"; exit 1
    fi
    echo ":: Use billing account (${ACCOUNT_ID}) to setup project"
    echo ":: Creating project..."
    gcloud projects create "${PROJECT_ID}" --name="${PROJECT_NAME}" --no-enable-cloud-apis
    echo ":: Linking billing account..."
    gcloud beta billing projects link "${PROJECT_ID}" --billing-account="${ACCOUNT_ID}"

    echo ":: setup-run"
    bash run.sh setup-run
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
    echo ":: Configuring docker push ..."
    gcloud auth configure-docker
  ;;

  cleanup-run)
    echo ':: cloud run'
    gcloud beta run services delete "${APP_NAME}" \
      --project="${PROJECT_ID}" --platform="${PLATFORM}" --region="${REGION}" --quiet
    echo
    echo ':: image'
    gcloud container images list-tags "${IMAGE_NAME}" --format='get(digest)' \
      | xargs -I _arg_ gcloud container images delete "${IMAGE_NAME}@_arg_" --quiet --force-delete-tags
    echo
    echo ':: log'
    echo '(Not Implemented): gcloud logging logs delete ...'
  ;;

  *) echo ":: Command (${@}) not found" ;;
esac
