// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {VRFRequestV1} from "../src/VRFRequestV1.sol";

import {VRFRequestClient} from "../src/mocks/VRFRequestClient.sol";
import {VRFVerificationLib} from "../src/mocks/VRFVerificationLib.sol";

import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract VRFRequestTest is Test {
    VRFRequestV1 public vrfRequest;
    VRFVerificationLib public verificationLib;

    address admin;

    event RandomnessRequested(
        bytes32 indexed requestId,
        address indexed requester
    );

    event RandomnessReceived(
        bytes32 indexed requestId,
        uint256 randomness,
        VRFRequestV1.RequestStatus status
    );

    function setUp() public {
        admin = vm.randomAddress();
        verificationLib = new VRFVerificationLib();

        address proxy = Upgrades.deployUUPSProxy(
            "VRFRequestV1.sol",
            abi.encodeCall(
                VRFRequestV1.initialize,
                (admin, address(verificationLib), address(0),address(0), 1337, 112000)
            )
        );

        vrfRequest = VRFRequestV1(proxy);
    }

    function test_nonce() public {
        assertEq(vrfRequest.nonce(), 0);
    }

    function test_requestRandomness() public {
        VRFRequestClient client = new VRFRequestClient(address(vrfRequest));

        bytes memory parameters = vm.randomBytes(1);
        uint256 callbackGasLimit = vm.randomUint(1, 1000000);

        vm.expectEmit(false, true, true, false);
        emit RandomnessRequested(bytes32(0), address(client));

        bytes32 reqId = client.requestRandomness(parameters, callbackGasLimit);

        (
            address gotRequester,
            bytes memory gotParameters,
            uint256 gotCallbackGasLimit,
            uint256 gotFee,
            VRFRequestV1.RequestStatus gotStatus
        ) = vrfRequest.requests(reqId);

        assertEq(gotRequester, address(client));
        assertEq(gotParameters, parameters);
        assertEq(gotCallbackGasLimit, callbackGasLimit);
        assertEq(gotFee, 0);
        assert(gotStatus == VRFRequestV1.RequestStatus.PENDING);
        assertEq(vrfRequest.nonce(), 1);
    }

    function bytesToUint256(bytes memory data) public pure returns (uint256) {
        require(data.length >= 32, "Bytes array too short");
        return abi.decode(data, (uint256));
    }
}
