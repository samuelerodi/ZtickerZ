pragma solidity ^0.5.2;

/**
 * @title IAdmin
 * @dev Admin are responsible for assigning and removing frontend contracts.
 */
interface IAdmin {

  function isAdmin(address account) external view returns (bool);

  modifier onlyAdmin() {
    require(this.isAdmin(msg.sender));
    _;
  }

}
