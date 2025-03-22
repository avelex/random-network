// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IVRFProofVerifier} from "../interfaces/IVRFProofVerifier.sol";

contract VRFVerificationLib is IVRFProofVerifier {
    constructor() {}

    function verify(
        uint256[2] memory _publicKey,
        bytes memory _proof,
        bytes memory _message
    ) external pure override returns (bool) {
        return true;
    }
}