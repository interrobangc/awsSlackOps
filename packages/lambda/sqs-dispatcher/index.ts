import { LambdaClient, InvokeCommand } from '@aws-sdk/client-lambda';

const queueUrl: string | undefined = process.env.SQS_QUEUE_URL;

const lambdaConfig = process.env.AWS_ENDPOINT ? { endpoint: process.env.AWS_ENDPOINT } : {};
const lambdaClient = new LambdaClient(lambdaConfig);

const processRecord = async (sqsRecord: { body: string }): Promise<any> => {
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

  return lambdaClient.send(
    new InvokeCommand({
      FunctionName: message.lambdaName,
      InvocationType: 'Event',
      Payload: JSON.stringify(message),
    }),
  );
};

interface Event {
  Records: { body: string; messageId: string }[];
}

export const handler = async (event: Event) => {
  const response = { batchItemFailures: [] };

  if (!queueUrl) {
    throw new Error('Missing SQS_QUEUE_URL ENV Variable');
  }

  const promises = event.Records.map(async sqsRecord => processRecord(sqsRecord));

  await Promise.all(promises);

  return response;
};
