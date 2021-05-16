# Cloud Run Script

[gcloud cli](https://cloud.google.com/sdk/gcloud) wrapper script to easily deploy container on [Google Cloud Run](https://cloud.google.com/run).

# Usage

See [example](./example).

```bash
# Authorize google cloud sdk
$ gcloud auth login

# Configure project
$ cp run-config.example.sh run-config.sh # Then edit PROJECT_ID, IMAGE_NAME, etc...

# Setup project
$ bash run.sh setup-project # Skip if project already exists
$ bash run.sh setup-run

# Build and deploy container
$ docker-compose build
$ bash run.sh deploy

# Show application url
$ bash run.sh show url
https://my-app-hw5ykashuq-an.a.run.app

# Test server
$ curl https://my-app-hw5ykashuq-an.a.run.app
{"url":"/","method":"GET","headers":{"host":"my-app-hw5ykashuq-an.a.run.app","user-agent":"curl/7.76.1","accept":"*/*","x-cloud-trace-context":"692f458dbeddb30a2a95f0bc0bb450f2/8497070375744697512;o=1","x-client-data":"CgSM6ZsV","x-forwarded-for":"240f:102:6414:1:bee2:f74c:2ea5:a82b","x-forwarded-proto":"https","forwarded":"for=\"240f:102:6414:1:bee2:f74c:2ea5:a82b\";proto=https"}}

# Show application log
$ bash run.sh logs
2021-05-16T11:39:37.953919Z [app.js] Listening on port 8080
2021-05-16T11:39:38.022803Z ::ffff:169.254.8.129 - - [16/May/2021:11:39:38 +0000] "GET / HTTP/1.1" 200 384 "-" "curl/7.76.1"

# Cleanup resources
$ bash run.sh cleanup-run
$ bash run.sh cleanup-project
```
