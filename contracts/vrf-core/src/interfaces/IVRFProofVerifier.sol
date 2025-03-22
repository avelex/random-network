// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IVRFProofVerifier {
    function verify(
        uint256[2] memory _publicKey,
        bytes memory _proof,
        bytes memory _message
    ) external pure returns (bool);
}