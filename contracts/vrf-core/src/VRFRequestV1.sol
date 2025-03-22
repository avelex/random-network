// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import {IMailbox} from "hyperlane-xyz/interfaces/IMailbox.sol";
import {TypeCasts} from "hyperlane-xyz/libs/TypeCasts.sol";
import {IMessageRecipient} from "hyperlane-xyz/interfaces/IMessageRecipient.sol";
import {ISpecifiesInterchainSecurityModule, IInterchainSecurityModule} from "hyperlane-xyz/interfaces/IInterchainSecurityModule.sol";

import {IVRFProofVerifier} from "./interfaces/IVRFProofVerifier.sol";

/// @custom:oz-upgrades
contract VRFRequestV1 is
    UUPSUpgradeable,
    AccessControlUpgradeable,
    IMessageRecipient,
    ISpecifiesInterchainSecurityModule
{
    mapping(bytes32 => Request) public requests;
    uint256 public nonce;

    IMailbox public mailbox;
    IVRFProofVerifier public proofVerifier;
    IInterchainSecurityModule public ism;

    uint32 public currentChainId;

    uint32 public randomNetworkChainId;
    bytes32 public randomNetworkRecipient;

    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");

    string private constant RECEIVE_RANDOMNESS_SELECTOR =
        "receiveRandomness(bytes32,uint256)";

    struct Request {
        address requester;
        bytes parameters;
        uint256 callbackGasLimit;
        uint256 fee;
        RequestStatus status;
    }

    enum RequestStatus {
        PENDING,
        COMPLETED,
        FAILED
    }

    // === ERRORS ===
    error InvalidRequestStatus();
    error InvalidProof();

    // === EVENTS ===
    event RandomnessRequested(
        bytes32 indexed requestId,
        address indexed requester
    );

    event RandomnessReceived(
        bytes32 indexed requestId,
        uint256 randomness,
        RequestStatus status
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _admin,
        address _proofVerifier,
        address _ism,
        address _mailbox,
        uint32 _currentChainId,
        uint32 _randomNetworkChainId
    ) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(RELAYER_ROLE, _mailbox);

        proofVerifier = IVRFProofVerifier(_proofVerifier);
        mailbox = IMailbox(_mailbox);
        ism = IInterchainSecurityModule(_ism);
        currentChainId = _currentChainId;
        randomNetworkChainId = _randomNetworkChainId;
    }

    function _authorizeUpgrade(
        address /* newImplementation */
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function setRandomNetworkRecipient(
        address _recipient
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        randomNetworkRecipient = TypeCasts.addressToBytes32(_recipient);
    }

    function requestRandomness(
        bytes calldata parameters,
        uint256 callbackGasLimit
    ) external payable returns (bytes32) {
        bytes32 requestId = keccak256(
            abi.encode(currentChainId, msg.sender, nonce++, block.number)
        );

        requests[requestId] = Request({
            requester: msg.sender,
            parameters: parameters,
            callbackGasLimit: callbackGasLimit,
            fee: msg.value,
            status: RequestStatus.PENDING
        });

        bytes memory message = abi.encode(requestId);

        mailbox.dispatch{value: msg.value}(
            randomNetworkChainId,
            randomNetworkRecipient,
            message
        );

        emit RandomnessRequested(requestId, msg.sender);

        return requestId;
    }

    function interchainSecurityModule()
        external
        view
        returns (IInterchainSecurityModule)
    {
        return ism;
    }

    // Implement Hyperlane IMessageRecipient
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external payable onlyRole(RELAYER_ROLE) {
        (
            bytes32 requestId,
            bytes memory randomness,
            uint256[2] memory publicKey,
            bytes memory proof
        ) = abi.decode(_message, (bytes32, bytes, uint256[2], bytes));

        rawReceiveRandomness(requestId, publicKey, proof, randomness);
    }

    function rawReceiveRandomness(
        bytes32 requestId,
        uint256[2] memory publicKey,
        bytes memory proof,
        bytes memory randomness
    ) internal {
        Request storage request = requests[requestId];

        if (request.status != RequestStatus.PENDING) {
            revert InvalidRequestStatus();
        }

        if (!proofVerifier.verify(publicKey, proof, randomness)) {
            revert InvalidProof();
        }

        uint256 randomnessValue = bytesToUint256(randomness);

        (bool success, ) = request.requester.call{
            gas: request.callbackGasLimit
        }(
            abi.encodeWithSignature(
                RECEIVE_RANDOMNESS_SELECTOR,
                requestId,
                randomnessValue
            )
        );

        RequestStatus status = success
            ? RequestStatus.COMPLETED
            : RequestStatus.FAILED;
        request.status = status;

        emit RandomnessReceived(requestId, randomnessValue, status);
    }

    function bytesToUint256(bytes memory data) public pure returns (uint256) {
        require(data.length >= 32, "Bytes array too short");
        return abi.decode(data, (uint256));
    }
}
