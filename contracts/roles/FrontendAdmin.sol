pragma solidity ^0.5.2;

import "../roles/Roles.sol";
import "../utils/Ownable.sol";

/**
 * @title FrontendAdmin
 * @dev FrontendAdmins are responsible for assigning and removing frontend contracts.
 */
contract FrontendAdmin is Ownable {
    using Roles for Roles.Role;

    event FrontendAdminAdded(address indexed account);
    event FrontendAdminRemoved(address indexed account);

    Roles.Role private _frontendAdmins;

    constructor () internal {
        _addFrontendAdmin(msg.sender);
    }

    modifier onlyFrontendAdmin() {
        require(isFrontendAdmin(msg.sender));
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return isFrontendAdmin(account);
    }

    function isFrontendAdmin(address account) public view returns (bool) {
        return _frontendAdmins.has(account);
    }

    function addFrontendAdmin(address account) public onlyOwner {
        _addFrontendAdmin(account);
    }

    function removeFrontendAdmin(address account) public onlyOwner {
        _removeFrontendAdmin(account);
    }

    function renounceFrontendAdmin() public {
        _removeFrontendAdmin(msg.sender);
    }

    function _addFrontendAdmin(address account) internal {
        _frontendAdmins.add(account);
        emit FrontendAdminAdded(account);
    }

    function _removeFrontendAdmin(address account) internal {
        _frontendAdmins.remove(account);
        emit FrontendAdminRemoved(account);
    }
}
