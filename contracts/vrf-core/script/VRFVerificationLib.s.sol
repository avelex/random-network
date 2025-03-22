// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VRFVerificationLib} from "../src/VRFVerificationLib.sol";

contract VRFVerificationLibScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        new VRFVerificationLib();

        vm.stopBroadcast();
    }
}
