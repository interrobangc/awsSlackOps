const config = require('../config.json');

export const addDummyInputHandlers = (app, inputs) => {
  for (const key in inputs) {
    app.action(`${key}_select`, async ({ ack }) => {
      await ack();
    });
  }
};

const generateResponse = async ({ message, selectedEnv, selectedNets }) => {};

export const buildHandlerForMessage = (app, handlerConfig) => {
  const { messageRegex, inputs } = handlerConfig;

  addDummyInputHandlers(app, inputs);
};

export const buildHandlerForMessages = app => {
  config.messageHandlers.forEach(handlerConfig => {
    buildHandlerForMessage(app, handlerConfig);
  });
};
