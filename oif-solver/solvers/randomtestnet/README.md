# Random Testnet Hyperlane Solver

This solver listens for Hyperlane Mailbox Dispatch events on Arbitrum Sepolia and processes them on Random Testnet.

## Overview

The Random Testnet Hyperlane Solver is designed to:

1. Listen for `Dispatch` events from the Hyperlane Mailbox contract on Arbitrum Sepolia
2. Validate that the destination is Random Testnet (domain ID 112000)
3. Process the message and forward it to the Random Testnet network

## Configuration

Before using this solver, make sure to:

1. Update the Hyperlane Mailbox contract address in `config/metadata.ts` with the actual deployed address on Arbitrum Sepolia
2. Implement the actual contract call in the `fill` method of `filler.ts` to process the Hyperlane message on Random Testnet

## Usage

To run the solver:

```bash
yarn solver
```

This will start the solver, which will listen for Hyperlane Mailbox Dispatch events on Arbitrum Sepolia and process them on Random Testnet.

## Implementation Details

- **Listener**: Listens for the `Dispatch` event from the Hyperlane Mailbox contract on Arbitrum Sepolia
- **Filler**: Processes the message and forwards it to Random Testnet
- **Rules**: Validates that the destination is Random Testnet (domain ID 112000)

## Next Steps

To complete the implementation:

1. Deploy the necessary contracts on Random Testnet to process Hyperlane messages
2. Update the `fill` method in `filler.ts` to call the appropriate contract on Random Testnet
3. Test the end-to-end flow by sending a message from Arbitrum Sepolia to Random Testnet
