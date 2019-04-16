pragma solidity ^0.5.2;

import "../interface/IAdmin.sol";
import "../roles/Roles.sol";

/**
 * @title PauserRole
 * @dev PauserRoles are account that are entitled to stop a contract operation in case an emergency arise.
 * That could be represented by a contract vulnerability discovery, an ongoing contract upgrade or any greater cause.
 * PauserRoles are managed by contract admins, but they also might eventually renounce to the title of Pauser indipendently.
 */
contract PauserRole is IAdmin {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyAdmin {
        _addPauser(account);
    }

    function removePauser(address account) public onlyAdmin {
        _removePauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}
