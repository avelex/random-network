// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import {IInterchainSecurityModule} from "hyperlane-xyz/interfaces/IInterchainSecurityModule.sol";

/// @custom:oz-upgrades
contract VRFInterchainSecurityModule is
    UUPSUpgradeable,
    AccessControlUpgradeable,
    IInterchainSecurityModule
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _admin) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function _authorizeUpgrade(
        address /* newImplementation */
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function moduleType() external view returns (uint8) {
        return uint8(IInterchainSecurityModule.Types.NULL);
    }

    function verify(
        bytes calldata _metadata,
        bytes calldata _message
    ) external view returns (bool) {
        return true;
    }
}
