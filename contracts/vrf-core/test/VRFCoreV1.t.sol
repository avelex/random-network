// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {VRFCoreV1} from "../src/VRFCoreV1.sol";

import {VRFVerificationLib} from "../src/mocks/VRFVerificationLib.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract VRFCoreTest is Test {
    address admin;
    VRFCoreV1 vrfCore;

    function setUp() public {
        admin = vm.randomAddress();
        VRFVerificationLib verificationLib = new VRFVerificationLib();

        address proxy = Upgrades.deployUUPSProxy(
            "VRFCoreV1.sol",
            abi.encodeCall(
                VRFCoreV1.initialize,
                (admin, address(verificationLib), address(0))
            )
        );

        vrfCore = VRFCoreV1(proxy);
    }

    function test_verifySignature() public {
        bytes32 requestId = 0x5168c88fe85053f0315bd76ca190548bc2fe35236cda6bd0376e97e03fb62ff2;
        bytes memory randomness = hex'0f3441ac97d6ed42d878c1284bfc9907b04156e752e4453e28e58257b4d80f30';
        bytes memory proof = hex'02976cce0b66a994bb3e9d0d80de69b725d70ab83db56ca49d9fa4403982d1c27951440aa279d3e6fa39c72debd0ea7ea882236593cc7d2fe3e2a50370bbe566acfbcec68a3c982001bcf3d2d12e073465';
        
        bytes memory packed = abi.encodePacked(requestId, randomness, proof);
        bytes32 hashed = keccak256(packed);
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hashed)
        );

        console.logBytes32(ethSignedMessageHash);
    }
}
