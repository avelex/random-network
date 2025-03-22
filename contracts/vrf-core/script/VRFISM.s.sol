// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VRFInterchainSecurityModule} from "../src/VRFInterchainSecurityModule.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract VRFInterchainSecurityModuleScript is Script {
    function setUp() public {}

    function run() public {
        address admin = vm.envAddress("ADMIN");

        vm.startBroadcast();

        Upgrades.deployUUPSProxy(
            "VRFInterchainSecurityModule.sol",
            abi.encodeCall(
                VRFInterchainSecurityModule.initialize,
                (admin)
            )
        );

        vm.stopBroadcast();
    }
}