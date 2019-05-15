pragma solidity ^0.5.2;

import '../interface/IZtickyCoinZ.sol';
import "../roles/TimedRoles.sol";
import "../roles/BackendAdmin.sol";

/**
 * @title Backend
 * @notice Backend contracts are storage contracts managed by a BackendAdmin entitled to perform restricted actions.
 * Backend contracts allow special interactions to frontend contracts, which are special type of logic contracts
 * that act as relay contracts. This separation between frontend and backend contracts allows for separation
 * between data and logic and it gives a good approach to contract's logic upgradability.
 * The Backend admin role is special in that it is the only accounts allowed to add (or remove) a Frontend logic contract.
 */
contract Backend is BackendAdmin {

    using TimedRoles for TimedRoles.Role;

    event FrontendAdded(address indexed contractAddress);
    event FrontendRemoved(address indexed contractAddress);

    /* @dev Use timed roles in order to control timing of frontend activation */
    TimedRoles.Role private _frontends;

    /**
     * @dev Requires a specific frontend activation time for security reasons.
     * Given that Frontends have access to special sensitive functions, and that the
     * Backend Admin is the only authority able to approve a new frontend, an elapsed time
     * of 2 days is required for every newly added frontend to become active.
     * This is a measure that mitigates the authority of the Backend Admin as a single
     * central point of failure.
     **/
    uint256 public frontendActivationTime = 172800;
    /* uint256 public frontendActivationTime = 3; */

    /**
     * @notice Make sure the caller is an allowed frontend.
     */
    modifier onlyFrontend() {
        require(isFrontend(msg.sender), "Not authorized. Must be a Frontend.");
        _;
    }

    /**
     * @dev Internal function to add a frontend contract.
     */
    function _addFrontend(address contractAddress) internal {
      _frontends.add(contractAddress);
      emit FrontendAdded(contractAddress);
    }

    /**
     * @dev Internal function to remove a frontend contract.
     */
    function _removeFrontend(address contractAddress) internal {
      _frontends.remove(contractAddress);
      emit FrontendRemoved(contractAddress);
    }

    /**
     * @notice Implements backend methods.
     */
    function isBackend() public pure returns (bool) {
        return true;
    }

    /**
     * @notice Check if the address is an authorized frontend and if activation time has passed.
     * @param contractAddress The address of the frontend contract
     */
    function isFrontend(address contractAddress) public view returns (bool) {
        uint256 _ts = _frontends.has(contractAddress);
        return _ts!=0 && ((_ts + frontendActivationTime) < block.timestamp);
    }

    /**
     * @notice Add a frontend contract.
     * @param contractAddress The address of the frontend contract
     */
    function addFrontend(address contractAddress) public onlyBackendAdmin {
        _addFrontend(contractAddress);
    }

    /**
     * @notice Remove a frontend contract.
     * @param contractAddress The address of the frontend contract
     */
    function removeFrontend(address contractAddress) public onlyBackendAdmin {
        _removeFrontend(contractAddress);
    }

}
