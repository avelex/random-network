// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IVRFRequester {
    function requestRandomness(
        bytes calldata parameters,
        uint256 callbackGasLimit
    ) external payable returns (bytes32);
}
    