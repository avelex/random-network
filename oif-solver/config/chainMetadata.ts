import { z } from "zod";

//import {  chainMetadata as defaultChainMetadata } from "@hyperlane-xyz/registry";

import type { ChainMap, ChainMetadata } from "@hyperlane-xyz/sdk";
import { ChainMetadataSchema } from "@hyperlane-xyz/sdk";

import { objMerge } from "@hyperlane-xyz/utils";

const customChainMetadata = {
  // Example custom configuration
  randomtestnet: {
    name: "randomtestnet",
    chainId: 112000,
    domainId: 112000,
    protocol: "ethereum",
    rpcUrls: [
      {
        http: "http://nitro-node:8547",
        pagination: {
          maxBlockRange: 1000,
        },
      },
    ],
  },
  arbitrumsepolia: {
    name: "arbitrumsepolia",
    chainId: 421614,
    domainId: 421614,
    protocol: "ethereum",
    rpcUrls: [
      {
        http: "https://arbitrum-sepolia.infura.io/v3/18dc852a5a164c14bfd0777052c107a0",
        pagination: {
          maxBlockRange: 1000,
        },
      },
    ],
  },
};

const chainMetadata = objMerge<ChainMap<ChainMetadata>>(
  customChainMetadata,
  customChainMetadata,
  10,
  true,
);

z.record(z.string(), ChainMetadataSchema).parse(chainMetadata);

export { chainMetadata };
