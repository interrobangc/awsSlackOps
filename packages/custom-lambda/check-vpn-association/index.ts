import { App } from '@slack/bolt';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';

const queueUrl: string | undefined = process.env.SQS_QUEUE_URL;

// Assuming you have a config object defined somewhere in your actual code
const sqsClient = new SQSClient({});

const app = new App({
  token: process.env.SLACK_BOT_TOKEN,
  // @ts-ignore
  receiver: {
    init: () => {}, // no receiver
  },
});

interface Payload {
  payload: {
    body: {
      channel: {
        id: string;
      };
      message: {
        thread_ts: string;
      };
      user: {
        id: string;
      };
    };
  };
}

export const handler = async (payload: Payload) => {
  const channel: string = payload.payload.body.channel.id;
  const thread_ts: string = payload.payload.body.message.thread_ts;
  const userId: string = payload.payload.body.user.id;

  /**
   * TODO:
   *
   * If the
   */

  await app.client.chat.postMessage({
    channel,
    thread_ts,
    text: `<@${userId}> VPN association is complete!`,
  });

  return { statusCode: 200 };
};
