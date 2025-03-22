
import z from 'zod';
import { BaseMetadataSchema, BaseIntentData } from '../types.js';
import type { ParsedArgs as BaseParsedArgs } from '../BaseFiller.js';

export const RandomtestnetMetadataSchema = BaseMetadataSchema.extend({
  // Add any additional metadata fields here if needed
});

export type RandomtestnetMetadata = z.infer<typeof RandomtestnetMetadataSchema>;

export interface IntentData extends BaseIntentData {
  // Hyperlane message data
  sender: string;
  destination: number;
  recipient: string; // bytes32
  message: string; // bytes
}

export interface ParsedArgs extends BaseParsedArgs {
  // Hyperlane Mailbox Dispatch event fields
  sender: string;
  destination: number;
  recipient: string; // bytes32
  message: string; // bytes
}
