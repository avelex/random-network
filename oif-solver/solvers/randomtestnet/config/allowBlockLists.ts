
import {
  type AllowBlockLists,
  AllowBlockListsSchema,
} from "../../../config/types.js";

// Example config
// [
//   {
//       senderAddress: "*",
//       destinationDomain: ["1"],
//       recipientAddress: "*"
//   },
//   {
//       senderAddress: ["0xca7f632e91B592178D83A70B404f398c0a51581F"],
//       destinationDomain: ["42220", "43114"],
//       recipientAddress: "*"
//   },
//   {
//       senderAddress: "*",
//       destinationDomain: ["42161", "420"],
//       recipientAddress: ["0xca7f632e91B592178D83A70B404f398c0a51581F"]
//   }
// ]

// Mailbox addresses

const allowedAddresses = [
  '0x008635105b348396B6ccD18BB715A9b6Db0E0D12',
  '0x9bF90104DC52b645038780f5e4410eC036DD273d',
  '0xa6334941d20b76af46379606a80F73a9c1406586'
];

const allowBlockLists: AllowBlockLists = {
  allowList: [
    // Allow messages from any sender to any recipient on allowed chains
    // {
    //   senderAddress: "*",
    //   destinationDomain: ["arbitrumsepolia", "randomtestnet"],
    //   recipientAddress: "*"
    // },
    // Allow specific mailbox addresses as senders
    // {
    //   senderAddress: [ARBITRUM_SEPOLIA_MAILBOX, RANDOM_TESTNET_MAILBOX],
    //   destinationDomain: ["arbitrumsepolia", "randomtestnet"],
    //   recipientAddress: "*"
    // },
    // Allow specific mailbox addresses as recipients
    {
      senderAddress: allowedAddresses,
      destinationDomain: ["arbitrumsepolia", "randomtestnet", "optimismsepolia", "sepolia"],
      recipientAddress: allowedAddresses
    }
  ],
  blockList: [],
};

AllowBlockListsSchema.parse(allowBlockLists);

export default allowBlockLists;
