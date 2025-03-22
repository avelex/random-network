// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IVRFRequester} from "../interfaces/IVRFRequester.sol";

contract VRFRequestClient {
    IVRFRequester public vrfRequest;
    mapping(bytes32 => uint256) public randomnes;

    constructor(address _vrfRequest) {
        vrfRequest = IVRFRequester(_vrfRequest);
    }

    function requestRandomness(
        bytes calldata parameters,
        uint256 callbackGasLimit
    ) public payable returns (bytes32) {
        return vrfRequest.requestRandomness{value: msg.value}(parameters, callbackGasLimit);
    }

    function receiveRandomness(
        bytes32 requestId,
        uint256 randomness
    ) public {
        randomnes[requestId] = randomness;
    }
}
