// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {IMailbox} from "hyperlane-xyz/interfaces/IMailbox.sol";

import {IVRFProofVerifier} from "./interfaces/IVRFProofVerifier.sol";
import {IMessageRecipient} from "./interfaces/IMessageRecipient.sol";

/// @custom:oz-upgrades
contract VRFCoreV1 is
    UUPSUpgradeable,
    AccessControlUpgradeable,
    IMessageRecipient
{
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    mapping(bytes32 => RequestData) requests;
    EnumerableSet.Bytes32Set pendingRequests;

    IMailbox public mailbox;
    IVRFProofVerifier public proofVerifier;

    struct RequestData {
        uint32 origin;
        bytes32 sender;
        uint256 timestamp;
        RequestStatus status;
        // Execution Data
        address executor;
        uint256[2] executorPublicKey;
        bytes proof;
        bytes randomness;
    }

    enum RequestStatus {
        PENDING_EXECUTION,
        PENDING_VALIDATION,
        VALIDATED,
        FAILED
    }

    // === ERRORS ===
    error RequestAlreadyProcessed();
    error InvalidRequestStatus(RequestStatus got, RequestStatus expected);
    error InvalidValidator(address validator);
    error InvalidExecutorSignature(address executor);
    error InvalidProof();

    // === EVENTS ===
    event RequestReceived(bytes32 indexed requestId);
    event VRFExecuted(bytes32 indexed requestId);
    event ReceivedMessage(uint32 _origin, bytes32 _sender, string _data);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _admin,
        address _proofVerifier,
        address _mailbox
    ) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(RELAYER_ROLE, _mailbox);

        proofVerifier = IVRFProofVerifier(_proofVerifier);
        mailbox = IMailbox(_mailbox);
    }

    function _authorizeUpgrade(
        address /* newImplementation */
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function addRelayer(address relayer) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(RELAYER_ROLE, relayer);
    }

    function addExecutor(address executor) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(EXECUTOR_ROLE, executor);
    }

    // Implement Hyperlane IMessageRecipient
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external payable onlyRole(RELAYER_ROLE) {
        emit ReceivedMessage(_origin, _sender, string(_message));

        bytes32 requestId = abi.decode(_message, (bytes32));

        handleCrossChainRequest(requestId, _origin, _sender);
    }

    function handleCrossChainRequest(bytes32 requestId, uint32 origin, bytes32 sender) internal {
        if (requests[requestId].timestamp != 0) {
            revert RequestAlreadyProcessed();
        }

        requests[requestId].origin = origin;
        requests[requestId].sender = sender;
        requests[requestId].timestamp = block.timestamp;
        requests[requestId].status = RequestStatus.PENDING_EXECUTION;

        pendingRequests.add(requestId);

        emit RequestReceived(requestId);
    }

    function executeVRF(
        bytes32 requestId,
        uint256[2] calldata publicKey,
        bytes calldata randomness,
        bytes calldata proof,
        bytes calldata signature
    ) public payable onlyRole(EXECUTOR_ROLE) {
        RequestData storage req = requests[requestId];

        if (req.status != RequestStatus.PENDING_EXECUTION) {
            revert InvalidRequestStatus(
                req.status,
                RequestStatus.PENDING_EXECUTION
            );
        }

        if (
            !verifyExecutorSignature(
                requestId,
                randomness,
                proof,
                signature,
                msg.sender
            )
        ) {
            revert InvalidExecutorSignature(msg.sender);
        }

        if (!proofVerifier.verify(publicKey, proof, randomness)) {
            revert InvalidProof();
        }

        req.executor = msg.sender;
        req.executorPublicKey = publicKey;
        req.randomness = randomness;
        req.proof = proof;
        req.status = RequestStatus.VALIDATED;

        pendingRequests.remove(requestId);

        emit VRFExecuted(requestId);

        bytes memory message = abi.encode(requestId, randomness, publicKey, proof);

        mailbox.dispatch{value: msg.value}(req.origin, req.sender, message);
    }

    function verifyExecutorSignature(
        bytes32 requestId,
        bytes memory randomness,
        bytes memory proof,
        bytes memory signature,
        address signer
    ) public pure returns (bool) {
        bytes memory packed = abi.encodePacked(requestId, randomness, proof);
        bytes32 hashed = keccak256(packed);
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hashed)
        );

        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    function recoverSigner(
        bytes32 ethSignedMessageHash,
        bytes memory signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);

        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    function splitSignature(
        bytes memory sig
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}
