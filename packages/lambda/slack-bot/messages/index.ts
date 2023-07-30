import { App } from '@slack/bolt';
import { handleVpnMessage } from './vpn';

const initMessageHandlers = (app: App): void => {
  handleVpnMessage(app);
};

export { initMessageHandlers };