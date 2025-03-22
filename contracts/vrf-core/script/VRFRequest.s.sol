// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VRFRequestV1} from "../src/VRFRequestV1.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {IMailbox} from "hyperlane-xyz/interfaces/IMailbox.sol";

contract VRFRequestV1Script is Script {
    function setUp() public {}

    function run() public {
        address admin = vm.envAddress("ADMIN");
        address verificationLib = vm.envAddress("VERIFICATION_LIB");
        address ism = vm.envAddress("ISM");
        address mailbox = vm.envAddress("MAILBOX");
        uint32 currentChainId = uint32(vm.envUint("CHAIN_ID"));
        uint32 randomChainId = uint32(112000);
        address randomNetworkRecipient = vm.envAddress("RANDOM_CORE");

        vm.startBroadcast();

        address proxy = Upgrades.deployUUPSProxy(
            "VRFRequestV1.sol",
            abi.encodeCall(
                VRFRequestV1.initialize,
                (admin, verificationLib, ism, mailbox, currentChainId, randomChainId)
            )
        );

        VRFRequestV1(proxy).setRandomNetworkRecipient(randomNetworkRecipient);

        vm.stopBroadcast();
    }
}


contract VRFRequestV1SetRandomNetworkRecipientScript is Script {
    function setUp() public {}

    function run() public {
        address vrfRequest = vm.envAddress("VRF_REQUEST");
        address recipient = vm.envAddress("RECIPIENT");

        VRFRequestV1 proxy = VRFRequestV1(vrfRequest);

        vm.startBroadcast();

        proxy.setRandomNetworkRecipient(recipient);

        vm.stopBroadcast();
    }
}


contract VRFRequestV1MailboxScript is Script {
    function setUp() public {}

    function run() public {
        address mailbox = vm.envAddress("MAILBOX");
        bytes memory message = hex'030000000d0001b5800000000000000000000000009bf90104dc52b645038780f5e4410ec036dd273d00066eee000000000000000000000000008635105b348396b6ccd18bb715a9b6db0e0d12cd529bc22ea77c069e40b14407c20aac6273efd98a15b38fd7e0500bf593e1ff00000000000000000000000000000000000000000000000000000000000000a0f781bb872e7a2eac21fa53f49cdd487c39abb82ef504755eb577fd6ac04aacffc91c6926277bd83cee9a9d79125f0dc9738073fdd2bb1e1c81ee38b123984b2c00000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000002034c693c0b57c0c330f1b70e437b8bd9d2984c417f1b0914aa9fce023c82d5c3c000000000000000000000000000000000000000000000000000000000000005103e1685d689a5e1b4753106d2a5b36f51f85267d5630f62be19ec280920c2117e1363a80d268ece3cb3b9dc4ce648523ef665d9b59b3106b20215c3cb226569aeba3ad91766d5d630809d71e2f59733038000000000000000000000000000000';
        bytes memory metadata = new bytes(0);

        vm.startBroadcast();

        IMailbox(mailbox).process(metadata, message);

        vm.stopBroadcast();
    }
}