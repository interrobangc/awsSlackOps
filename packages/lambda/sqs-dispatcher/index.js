const { Lambda, SQS } = require('aws-sdk');

const queueUrl = process.env.SQS_QUEUE_URL;

const lambdaConfig = process.env.AWS_ENDPOINT ? { endpoint: process.env.AWS_ENDPOINT } : {};
const lambda = new Lambda(lambdaConfig);
const sqs = new SQS();

const processRecord = async sqsRecord => {
  const message = JSON.parse(sqsRecord.body);

  console.log('doing stuff!');
  console.dir(message);

  const now = new Date().getTime();

  if (message.executeAt >= now) {
    console.log('message is not ready to be processed yet');
    console.log(`${message.executeAt} <= ${now}`);

    // This will only work for a tasks less than a few minutes away. For anything else we'll need to send another message to the queue with `DelaySeconds` set appropriately.
    return setTimeout(() => processRecord(sqsRecord), 1000 * 5);
  }

  return lambda
    .invoke({
      FunctionName: message.lambdaName,
      InvocationType: 'Event',
      Payload: JSON.stringify(message),
    })
    .promise();
};

module.exports.handler = async event => {
  const response = { batchItemFailures: [] };

  try {
    if (!queueUrl) {
      throw new Error('Missing SQS_QUEUE_URL ENV Variable');
    }

    const promises = event.Records.map(async sqsRecord => processRecord(sqsRecord));

    await Promise.all(promises);

    return response;
  } catch (err) {
    // SSM failures and other major setup exceptions will cause a failure of all messages sending them to DLQ
    // which should be the same as the completed queue right now.
    console.error(err);

    // We fail all messages here and rely on SQS retry/DLQ because we hit
    // a fatal error before we could process any of the messages. The error
    // handler, whether loop based in hrm-services or lambda based here, will
    // need to be able to handle these messages that will end up in the completed
    // queue without a completionPayload.
    response.batchItemFailures = event.Records.map(record => {
      return {
        itemIdentifier: record.messageId,
      };
    });

    return response;
  }
};
