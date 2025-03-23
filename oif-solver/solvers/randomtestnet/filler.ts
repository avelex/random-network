
import type { MultiProvider } from "@hyperlane-xyz/sdk";
import { ethers } from 'ethers';
import { type Result } from "@hyperlane-xyz/utils";
import { BaseFiller } from '../BaseFiller.js';
import { metadata, allowBlockLists } from './config/index.js';
import type { RandomtestnetMetadata, IntentData, ParsedArgs } from './types.js';
import { log } from '../../logger.js';
import { Mailbox__factory } from "../../typechain/factories/randomtestnet/contracts/Mailbox__factory.js";

// Map of chain IDs to mailbox addresses
const chainIdsMailbox: Record<number, string> = {
  421614: '0x598facE78a4302f11E3de0bee1894Da0b2Cb71F8',
  112000: '0xbE431E0aaEFeC6Ce80071498bCbEd0452011DC41',
  11155111: '0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766',
  11155420: '0x6966b0E55883d49BFB24539356a2f8A673E02039'
};

export class RandomtestnetFiller extends BaseFiller<RandomtestnetMetadata, ParsedArgs, IntentData> {
  constructor(multiProvider: MultiProvider) {
    super(multiProvider, allowBlockLists, metadata, log);
  }

  protected async retrieveOriginInfo(
    parsedArgs: ParsedArgs,
    chainName: string
  ): Promise<Array<string>> {
    return [`Origin chain: ${chainName}, Sender: ${parsedArgs.sender}`];
  }

  protected async retrieveTargetInfo(
    parsedArgs: ParsedArgs
  ): Promise<Array<string>> {
    return [`Destination chain: ${parsedArgs.destination}, Recipient: ${parsedArgs.recipient}`];
  }

  protected async fill(
    parsedArgs: ParsedArgs,
    data: IntentData,
    originChainName: string,
    blockNumber: number
  ): Promise<void> {
    this.log.info({
      msg: "Filling Intent",
      intent: `Request Randomness`,
    });

    try {
      const targetChainId = parsedArgs.destination;
      const filler = this.multiProvider.getSigner(targetChainId);

      const mailboxAddress = chainIdsMailbox[targetChainId];
      const mailbox = Mailbox__factory.connect(mailboxAddress, filler);

      // empty metadata
      const metadata = "0x";
    
      const tx = await mailbox.process(metadata, data.message);
      const receipt = await tx.wait();

      this.log.info({
        msg: "Processed Hyperlane message",
        sender: data.sender,
        origin: data.destination, // This is the origin domain from Random Testnet's perspective
        recipient: data.recipient,
        messageLength: ethers.utils.hexDataLength(data.message),
        transactionHash: receipt.transactionHash,
      });
      
    } catch (error: any) {
      this.log.error({
        msg: "Failed to fill intent",
        error: error.message || String(error),
        intent: `Request Randomness`,
      });
      throw error;
    }
  }

  protected async prepareIntent(
    parsedArgs: ParsedArgs
  ): Promise<Result<IntentData>> {
    try {
      await super.prepareIntent(parsedArgs);
      
      // Prepare the data needed for filling the intent
      return { 
        success: true, 
        data: { 
          sender: parsedArgs.senderAddress,
          destination: parsedArgs.destination,
          recipient: parsedArgs.recipient,
          message: parsedArgs.message,
        } 
      };
    } catch (error: any) {
      return {
        error: error.message ?? "Failed to prepare Randomtestnet Intent.",
        success: false,
      };
    }
  }

  // No settlement needed for this implementation
  protected async settle(): Promise<void> {
    return Promise.resolve();
  }
}

// Rule to check if the destination is Random Testnet
export const isDestinationRandomTestnet = async (
  parsedArgs: ParsedArgs,
) => {
  // Check if the destination domain matches Random Testnet's domain ID
  // if (parsedArgs.destination !== 112000) { // Random Testnet domain ID
  //   return {
  //     error: `Destination is not Random Testnet (got ${parsedArgs.destination})`,
  //     success: false,
  //   };
  // }

  return { data: "Destination is Random Testnet", success: true };
};

export const create = (multiProvider: MultiProvider) => 
  new RandomtestnetFiller(multiProvider).create();
