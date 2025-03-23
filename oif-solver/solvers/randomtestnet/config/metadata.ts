
import {
  type RandomtestnetMetadata,
  RandomtestnetMetadataSchema,
} from "../types.js";

// Hyperlane Mailbox contract addresses
const ARBITRUM_SEPOLIA_MAILBOX_ADDRESS = '0x598facE78a4302f11E3de0bee1894Da0b2Cb71F8';
const RANDOM_TESTNET_MAILBOX_ADDRESS = '0xbE431E0aaEFeC6Ce80071498bCbEd0452011DC41';
const OPTIMISM_SEPOLIA_MAILBOX_ADDRESS = '0x6966b0E55883d49BFB24539356a2f8A673E02039';
const SEPOLIA_MAILBOX_ADDRESS = '0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766';


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
    {
      address: OPTIMISM_SEPOLIA_MAILBOX_ADDRESS,
      chainName: "optimismsepolia",
    },
    {
      address: SEPOLIA_MAILBOX_ADDRESS,
      chainName: "sepolia",
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
