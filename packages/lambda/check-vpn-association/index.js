// const { Lambda } = require('aws-sdk');
const { App } = require('@slack/bolt');
const { SQS } = require('aws-sdk');

const queueUrl = process.env.SQS_QUEUE_URL;

const sqs = new SQS();

const app = new App({
  token: process.env.SLACK_BOT_TOKEN,
  receiver: {
    init: () => {}, // no receiver
  },
});

module.exports.handler = async payload => {
  const channel = payload.payload.body.channel.id;
  const thread_ts = payload.payload.body.message.thread_ts;
  const userId = payload.payload.body.user.id;

  await app.client.chat.postMessage({
    channel,
    thread_ts,
    text: `<@${userId}> VPN association is complete!`,
  });

  return { statusCode: 200 };
};
