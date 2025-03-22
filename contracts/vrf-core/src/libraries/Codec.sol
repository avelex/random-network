// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

library Codec {
    function decodeRequest(
        bytes calldata _message
    )
        public
        pure
        returns (
            bytes32 requestId,
            bytes32 sender,
            bytes32 recipient,
            uint32 sourceChainId,
            bytes memory parameters
        )
    {
        (requestId, sender, recipient, sourceChainId, parameters) = abi.decode(
            _message,
            (bytes32, bytes32, bytes32, uint32, bytes)
        );
    }

    function encodeRequest(
        bytes32 requestId,
        bytes32 sender,
        bytes32 recipient,
        uint32 sourceChainId,
        bytes memory parameters
    ) public pure returns (bytes memory) {
        return
            abi.encode(requestId, sender, recipient, sourceChainId, parameters);
    }
}
