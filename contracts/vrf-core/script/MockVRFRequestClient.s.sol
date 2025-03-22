// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VRFRequestV1} from "../src/VRFRequestV1.sol";
import {VRFRequestClient} from "../src/mocks/VRFRequestClient.sol";

contract VRFRequestClientScript is Script {
    function setUp() public {}

    function run() public {
        address vrfRequest = vm.envAddress("VRF_REQUEST");

        vm.startBroadcast();

        new VRFRequestClient(vrfRequest);

        vm.stopBroadcast();
    }
}

contract VRFRequestClientRequestRandomnessScript is Script {
    function setUp() public {}

    function run() public {
        address vrfClient = vm.envAddress("VRF_CLIENT");
        uint256 fee = vm.envUint("FEE");

        VRFRequestClient proxy = VRFRequestClient(vrfClient);
        bytes memory parameters = vm.randomBytes(8);
        uint256 callbackGasLimit = 300_000;

        vm.startBroadcast();
        
        proxy.requestRandomness{value: fee}(parameters, callbackGasLimit);

        vm.stopBroadcast();
    }
}

contract VRFRequestClientGetRandomnessScript is Script {
    function setUp() public {}

    function run() public {
        address vrfClient = vm.envAddress("VRF_CLIENT");
        bytes32 requestId = vm.envBytes32("REQUEST_ID");

        VRFRequestClient proxy = VRFRequestClient(vrfClient);

        uint256 randomness = proxy.randomnes(requestId);
        console.log("Randomness:", randomness);
    }
}
