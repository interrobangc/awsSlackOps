# awsSlackOps

## Local Development

run `npm ci` to install dependencies

run `npm start` to start run the system in localstack locally.

You will be asked for a slack application token and a slack signing secret. You can get them from https://api.slack.com/apps.

This will output an invoke url. Take note of the id that makes up the first part of the url. For example, if the final output is:

```
invoke_url = "https://vl1zg47nmw.execute-api.eu-west-1.amazonaws.com/local"
```

you need the code `vl1zg47nmw`.

You will need it for a later step.

run `npm run ngrok` to start ngrok and expose the localstack endpoint to the internet.

Take note of the forwarding url. For example, if the final output is:

```
Forwarding                    https://73f8-67-218-212-63.ngrok-free.app -> http://localhost:4566
```

You need the URL: `https://73f8-67-218-212-63.ngrok-free.app`.

You will combine the code and the url into something like this which you will use to configure the slack app:

```
https://73f8-67-218-212-63.ngrok-free.app/restapis/vl1zg47nmw/local/_user_request_/
```

In the Interactivity & Shortcuts section of the slack app configuration, you will need to enable interactivity and enter the url you just created in the Request URL field.

In the Event Subscriptions section of the slack app configuration, you will need to enable events and enter the url you just created in the Request URL field. It is likely that the verification step will fail on the first try because the lambda is cold and takes a while to start. Just try again after a few seconds.

### Requirements
