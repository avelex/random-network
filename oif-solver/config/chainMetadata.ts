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
        http: "https://arbitrum-sepolia-rpc.publicnode.com",
        pagination: {
          maxBlockRange: 1000,
        },
      },
    ],
  },
  sepolia: {
    name: "sepolia",
    chainId: 11155111,
    domainId: 11155111,
    protocol: "ethereum",
    rpcUrls: [
      {
        http: "https://sepolia-rpc.publicnode.com",
        pagination: {
          maxBlockRange: 1000,
        },
      },
    ],
  },
  optimismsepolia: {
    name: "optimismsepolia",
    chainId: 11155420,
    domainId: 11155420,
    protocol: "ethereum",
    rpcUrls: [
      {
        http: "https://optimism-sepolia-rpc.publicnode.com",
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
