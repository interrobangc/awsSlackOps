const { handleVpnMessage } = require('./vpn');

const initMessageHandlers = app => {
  handleVpnMessage(app);
};

module.exports.initMessageHandlers = initMessageHandlers;
