const { Lambda } = require('aws-sdk');

/*
Slack has a 3 second timeout for requests. If it doesn't receive a 200 within 3 seconds
it will retry the request. Cold start lambdas can be slow. This dispatcher is as lightweight
as possible to ensure it responds to Slack within 3 seconds. All it does is trigger another
lambda function that does the actual work.

See: https://github.com/slackapi/bolt-js/issues/816#issuecomment-971386939
*/

const lambdaConfig = process.env.AWS_ENDPOINT ? { endpoint: process.env.AWS_ENDPOINT } : {};
const lambda = new Lambda(lambdaConfig);

module.exports.handler = async event => {
  return await lambda
    .invoke({
      FunctionName: process.env.SLACK_BOT_LAMBDA_NAME,
      InvocationType: 'Event',
      Payload: JSON.stringify(event),
    })
    .promise()
    .then(() => {
      return { statusCode: 200 };
    });
};
