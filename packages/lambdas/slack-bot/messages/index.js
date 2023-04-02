const { handleVpnMessage } = require('./vpn');
const config = require('../config.json');

const initMessageHandlers = app => {
  console.log('config dump', config);

  handleVpnMessage(app);
};

module.exports.initMessageHandlers = initMessageHandlers;
