pragma solidity ^0.5.2;

import "../roles/Roles.sol";
import "./BackendAdmin.sol";

/**
 * @title Backend
 * @dev Frontend contracts have been approved by a BackendAdmin to perform restricted actions.
 * This role is special in that the only accounts that can add it are BackendAdmins (who can also remove it).
 */
contract Backend is BackendAdmin {
    using Roles for Roles.Role;

    event FrontendAdded(address indexed account);
    event FrontendRemoved(address indexed account);

    Roles.Role private _frontends;

    modifier onlyFrontend() {
        require(isFrontend(msg.sender));
        _;
    }

    function isFrontend(address account) public view returns (bool) {
        return _frontends.has(account);
    }

    function addFrontend(address account) public onlyBackendAdmin {
        _addFrontend(account);
    }

    function removeFrontend(address account) public onlyBackendAdmin {
        _removeFrontend(account);
    }

    function _addFrontend(address account) internal {
        _frontends.add(account);
        emit FrontendAdded(account);
    }

    function _removeFrontend(address account) internal {
        _frontends.remove(account);
        emit FrontendRemoved(account);
    }
}
