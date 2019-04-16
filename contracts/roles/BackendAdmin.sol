pragma solidity ^0.5.2;

import "../interface/IAdmin.sol";
import "../roles/Roles.sol";
import "../utils/Ownable.sol";

/**
 * @title BackendAdmin
 * @dev BackendAdmins are responsible for managing backend contracts, and among other things, assign frontend contracts
 * i.e. contracts that implement the logic.
 * BackendAdmins can only be added or removed by the owner of the contract, but they might eventually renounce to the title indipendently
 */
contract BackendAdmin is IAdmin, Ownable {
    using Roles for Roles.Role;

    event BackendAdminAdded(address indexed account);
    event BackendAdminRemoved(address indexed account);

    Roles.Role private _backendAdmins;

    constructor () internal {
        _addBackendAdmin(msg.sender);
    }

    modifier onlyBackendAdmin() {
        require(isBackendAdmin(msg.sender));
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return isBackendAdmin(account);
    }

    function isBackendAdmin(address account) public view returns (bool) {
        return _backendAdmins.has(account);
    }

    function addBackendAdmin(address account) public onlyOwner {
        _addBackendAdmin(account);
    }

    function removeBackendAdmin(address account) public onlyOwner {
        _removeBackendAdmin(account);
    }

    function renounceBackendAdmin() public {
        _removeBackendAdmin(msg.sender);
    }

    function _addBackendAdmin(address account) internal {
        _backendAdmins.add(account);
        emit BackendAdminAdded(account);
    }

    function _removeBackendAdmin(address account) internal {
        _backendAdmins.remove(account);
        emit BackendAdminRemoved(account);
    }
}
