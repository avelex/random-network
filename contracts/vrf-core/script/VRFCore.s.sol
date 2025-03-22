// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoreV1} from "../src/VRFCoreV1.sol";
import {Upgrades, UnsafeUpgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract VRFCoreV1Script is Script {
    function setUp() public {}

    function run() public {
        address admin = vm.envAddress("ADMIN");
        address verificationLib = vm.envAddress("VERIFICATION_LIB");
        address mailbox = vm.envAddress("MAILBOX");

        vm.startBroadcast();

        Upgrades.deployUUPSProxy(
            "VRFCoreV1.sol",
            abi.encodeCall(VRFCoreV1.initialize, (admin, verificationLib, mailbox))
        );

        vm.stopBroadcast();
    }
}

contract VRFCoreUpgradeScript is Script {
    function setUp() public {}

    function run() public {
        address proxy = vm.envAddress("VRF_CORE");

        vm.startBroadcast();

        VRFCoreV1 newImpl = new VRFCoreV1();
        
        UnsafeUpgrades.upgradeProxy(proxy, address(newImpl), "");

        vm.stopBroadcast();
    }
}

contract VRFCoreSetupExecutorScript is Script {
    function setUp() public {}

    function run() public {
        address vrfCore = vm.envAddress("VRF_CORE");
        address executor = vm.envAddress("EXECUTOR");

        VRFCoreV1 proxy = VRFCoreV1(vrfCore);

        vm.startBroadcast();

        proxy.addExecutor(executor);

        vm.stopBroadcast();
    }
}


contract VRFCoreSetupRelayerScript is Script {
    function setUp() public {}

    function run() public {
        address vrfCore = vm.envAddress("VRF_CORE");
        address relayer = vm.envAddress("RELAYER");

        VRFCoreV1 proxy = VRFCoreV1(vrfCore);

        vm.startBroadcast();

        proxy.addRelayer(relayer);

        vm.stopBroadcast();
    }
}