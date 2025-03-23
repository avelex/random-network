
import { BaseListener } from '../BaseListener.js';
import { metadata } from './config/index.js';
import type { ParsedArgs } from './types.js';
import { log } from '../../logger.js';
import type { TypedListener } from "../../typechain/common.js";
import { Mailbox__factory } from "../../typechain/factories/randomtestnet/contracts/Mailbox__factory.js";
import type {
  Mailbox,
  DispatchEvent,
} from "../../typechain/randomtestnet/contracts/Mailbox.js";
import { bytes32ToAddress } from '@hyperlane-xyz/utils';

// Map of chain IDs to chain names
const chainIdsToName: Record<string, string> = {
  '421614': 'arbitrumsepolia',
  '112000': 'randomtestnet',
  '11155111': 'sepolia',
  '11155420': 'optimismsepolia'
};

export class RandomtestnetListener extends BaseListener<Mailbox, DispatchEvent, ParsedArgs> {
  constructor() {
    super(
      Mailbox__factory,
      'Dispatch',
      { contracts: [...metadata.intentSources], protocolName: metadata.protocolName },
      log
    );
  }


  protected parseEventArgs(args: Parameters<TypedListener<DispatchEvent>>): ParsedArgs {
    const [sender, destination, recipient, message] = args;

    const destinationChainName = chainIdsToName[destination.toString()];
    const recipientAddress = bytes32ToAddress(recipient);
    
    return {
      orderId: message,
      senderAddress: sender,
      recipients: [{
        destinationChainName: destinationChainName,
        recipientAddress: recipientAddress,
      }],
      sender: sender,
      destination: destination,
      recipient: recipientAddress,
      message: message,
    };
  }
}

export const create = () => new RandomtestnetListener().create();
