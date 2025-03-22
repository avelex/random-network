
import {
  type RandomtestnetMetadata,
  RandomtestnetMetadataSchema,
} from "../types.js";

// Hyperlane Mailbox contract address on Arbitrum Sepolia
// Replace this with the actual deployed Mailbox contract address
const ARBITRUM_SEPOLIA_MAILBOX_ADDRESS = '0x598facE78a4302f11E3de0bee1894Da0b2Cb71F8'; // Example address, replace with actual
const RANDOM_TESTNET_MAILBOX_ADDRESS = '0xbE431E0aaEFeC6Ce80071498bCbEd0452011DC41'; // Example address, replace with actual

const metadata: RandomtestnetMetadata = {
  protocolName: "Random VRF",
  intentSources: [
    // testnet
    {
      address: ARBITRUM_SEPOLIA_MAILBOX_ADDRESS,
      chainName: "arbitrumsepolia",
    },
    {
      address: RANDOM_TESTNET_MAILBOX_ADDRESS,
      chainName: "randomtestnet",
    },
  ]
  // customRules: {
  //   rules: [
  //     {
  //       name: "filterByTokenAndAmount",
  //       args: {
  //         "11155420": {
  //           "0x5f94BC7Fb4A2779fef010F96b496cD36A909E818": BigInt(50e18),
  //           [AddressZero]: BigInt(5e15),
  //         },
  //         "84532": {
  //           "0x5f94BC7Fb4A2779fef010F96b496cD36A909E818": BigInt(50e18),
  //           [AddressZero]: BigInt(5e15),
  //         },
  //         "421614": {
  //           "0xaf88d065e77c8cC2239327C5EDb3A432268e5831": null,
  //           [AddressZero]: BigInt(5e15),
  //         },
  //         "11155111": {
  //           "0x5f94BC7Fb4A2779fef010F96b496cD36A909E818": BigInt(5e18),
  //           [AddressZero]: BigInt(5e10),
  //         },
  //       },
  //     },
  //     {
  //       name: "intentNotFilled",
  //     },
  //   ],
  // },
};

RandomtestnetMetadataSchema.parse(metadata);

export default metadata;
