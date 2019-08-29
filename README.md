Cloud Run Script

Goal:

- Deploy container to [Google Cloud Run](https://cloud.google.com/run/) as easily as Heroku container.

Secondary Objectives:

- Getting familiar with google cloud's resource in general
- Getting familiar with gcloud cli

===

Usage

```
## Setup ##
$ # Edit PROJECT_ID, APP_NAME, LOCAL_BUILD_CMD, etc.. in run.sh
$ # bash run.sh setup-project # if project doesn't exist yet
$ # bash run.sh setup-run     # if project already exists


## Deployment ##
$ bash run.sh deploy
...

$ bash run.sh show url
https://my-app-ykb4y23ena-an.a.run.app

$ curl https://my-app-ykb4y23ena-an.a.run.app
{"url":"/","method":"GET","headers":{"host":"my-app-ykb4y23ena-an.a.run.app","user-agent":"curl/7.65.3","accept":"*/*","x-cloud-trace-context":"54befe0665ddb07b365ffc29d465657a/1168116581818008579;o=1","x-forwarded-for":"210.149.251.131","x-forwarded-proto":"https","forwarded":"for=\"210.149.251.131\";proto=https","content-length":"0"}}

$ bash run.sh logs
2019-08-29T05:15:41.524485Z :: Listening on port  8080
2019-08-29T05:16:40.480937Z ::ffff:169.254.8.129 - GET / HTTP/1.1 200 338 - 4.922 ms

## Cleanup ##
$ bash run.sh cleanup-run     # delete only resources used for cloud run app
$ bash run.sh cleanup-project # delete whole project
```
