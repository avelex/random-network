// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IVRFProofVerifier} from "./interfaces/IVRFProofVerifier.sol";
import {VRF} from "./libraries/VRF.sol";


contract VRFVerificationLib is IVRFProofVerifier {
    constructor() {}

    function verify(
        uint256[2] memory _publicKey,
        bytes memory _proof,
        bytes memory _message
    ) external pure override returns (bool) {
        uint256[4] memory proof = VRF.decodeProof(_proof);
        return VRF._verify(_publicKey, proof, _message);
    }
}