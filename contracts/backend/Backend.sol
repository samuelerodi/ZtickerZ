pragma solidity ^0.5.2;

import "../roles/TimedRoles.sol";
import "../roles/BackendAdmin.sol";

/**
 * @title Backend
 * @dev Frontend contracts have been approved by a BackendAdmin to perform restricted actions.
 * This role is special in that the only accounts that can add it are BackendAdmins (who can also remove it).
 */
contract Backend is BackendAdmin {
    using TimedRoles for TimedRoles.Role;

    event FrontendAdded(address indexed contractAddress);
    event FrontendRemoved(address indexed contractAddress);

    uint256 public frontendActivationTime = 172800;

    TimedRoles.Role private _frontends;

    modifier onlyFrontend() {
        require(isFrontend(msg.sender));
        _;
    }

    function isBackend() public pure returns (bool) {
        return true;
    }

    function isFrontend(address contractAddress) public view returns (bool) {
        uint256 _ts = _frontends.has(contractAddress);
        return _ts!=0 && ((_ts + frontendActivationTime) < block.timestamp);
    }

    function addFrontend(address contractAddress) public onlyBackendAdmin {
        _addFrontend(contractAddress);
    }

    function removeFrontend(address contractAddress) public onlyBackendAdmin {
        _removeFrontend(contractAddress);
    }

    function _addFrontend(address contractAddress) internal {
        _frontends.add(contractAddress);
        emit FrontendAdded(contractAddress);
    }

    function _removeFrontend(address contractAddress) internal {
        _frontends.remove(contractAddress);
        emit FrontendRemoved(contractAddress);
    }
}
