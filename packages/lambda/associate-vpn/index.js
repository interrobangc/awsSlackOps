const { App } = require('@slack/bolt');
const { SQS } = require('aws-sdk');

const queueUrl = process.env.SQS_QUEUE_URL;

const sqs = new SQS();

const app = new App({
  token: process.env.SLACK_BOT_TOKEN,
  receiver: {
    init: () => {}, // override receiver
  },
});

const parseConfig = body => {
  const env = body.state.values.env_select_input.env_select.selected_option?.value;
  const nets = body.state.values.net_select_input.net_select.selected_options?.map(n => n.value);
  const thread_ts = body.message.thread_ts;
  const userId = body.user.id;
  const channel = body.channel.id;

  return { env, nets, thread_ts, userId, channel };
};

const handleSuccess = async (body, { env, nets, thread_ts, userId, channel }) => {
  text = `<@${userId}> I'm associating the ${nets.join(', ')} network${
    nets.length > 1 ? 's' : ''
  } with the ${env} VPN for you! I'll let you know when it is associated.`;

  await app.client.chat.postMessage({
    channel,
    thread_ts,
    text,
  });

  // Message to be sent to SQS to invoke the check-vpn-association lambda on a timer
  const message = {
    executeAt: Date.now(), // if timeframe is less than 15 minutes DelaySeconds should be used
    lambdaName: `${process.env.NODE_ENV}-slack-bot-check-vpn-association`,
    payload: {
      // TODO: add data to payload to be used in check-vpn-association lambda
      body,
      attemptNumber: 0,
    },
  };

  await sqs
    .sendMessage({
      DelaySeconds: 30,
      MessageBody: JSON.stringify(message),
      QueueUrl: queueUrl,
    })
    .promise();

  console.log(`sent sqs message to ${queueUrl}`, message);
};

const associateNetwork = async (body, { env, nets, thread_ts, userId, channel }) => {
  if (!env || !nets.length) return;

  //TODO: Check to see if network is already associated and send message if it is.

  try {
    //TODO: associate the correct network to the VPN based on environment and network
    await handleSuccess(body, { env, nets, thread_ts, userId, channel });
  } catch (error) {
    console.error(error);
    await app.client.chat.postMessage({
      channel,
      thread_ts,
      text: `<@${userId}> I'm sorry, I was unable to associate the network${
        nets.length > 1 ? 's' : ''
      } with the ${env} VPN. Please try again later.`,
    });
  }
};

module.exports.handler = async ({ body }) => {
  const config = parseConfig(body);
  const { env, nets, thread_ts, userId, channel } = config;

  if (!env) {
    await app.client.chat.postMessage({
      channel,
      thread_ts,
      text: `<@${userId}>Please choose an environment!`,
    });
  }

  if (!nets.length) {
    await app.client.chat.postMessage({
      channel,
      thread_ts,
      text: `<@${userId}>Please choose at least one network!`,
    });
  }

  await associateNetwork(body, config);

  return { statusCode: 200 };
};
