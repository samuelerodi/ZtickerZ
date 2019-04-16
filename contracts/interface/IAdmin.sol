pragma solidity ^0.5.2;

/**
 * @title IAdmin
 * @notice Admins have special permissions and are responsible for mantaining a contract.
 */
interface IAdmin {

  /**
   * @dev It MUST implement the function that checks whether an address is an admin
   */
  function isAdmin(address account) external view returns (bool);

  /**
   * @dev This modifier checks if the caller is an admin of the contract
   */
  modifier onlyAdmin() {
    require(this.isAdmin(msg.sender));
    _;
  }

}
