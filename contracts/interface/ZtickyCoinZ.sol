pragma solidity ^0.5.7;

interface ZtickyCoinZInterface {
  //BASE
  function mint(address _to, uint256 _amount) public returns(bool);
  function burn(uint256 _value) public returns(bool);
  function frontendApprove(address spender, uint256 value) public returns (bool);
  //ERC20
  function totalSupply() public view returns (uint256);
  function balanceOf(address owner) public view returns (uint256);
  function allowance(address owner, address spender) public view returns (uint256);
  //ERC20Detailed
  function name() public view returns (string memory);
  function symbol() public view returns (string memory);
  function decimals() public view returns (uint8);
  //ERC20Pausable
  function transfer(address to, uint256 value) public returns (bool);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  function increaseAllowance(address spender, uint addedValue) public returns (bool success);
  function decreaseAllowance(address spender, uint subtractedValue) public returns (bool success);
  //Pausable
  function paused() public view returns (bool);
  function pause() public;
  function unpause() public;
  //PauserRole
  function isPauser(address account) public view returns (bool);
  function addPauser(address account) public;
  function renouncePauser() public;
  //Ownable
  function owner() public view returns (address);
  function isOwner() public view returns (bool);
  function transferOwnership(address newOwner) public;
  //Backend
  function isFrontend(address account) public view returns (bool);
  function addFrontend(address account) public;
  function removeFrontend(address account) public;
  //BackendAdmin
  function isBackendAdmin(address account) public view returns (bool);
  function addBackendAdmin(address account) public;
  function removeBackendAdmin(address account) public;
  function renounceBackendAdmin() public;
  //HasNoEther
  function reclaimEther() external;
  function() external;

  //Events
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Paused(address account);
  event Unpaused(address account);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);
  event FrontendAdded(address indexed account);
  event FrontendRemoved(address indexed account);
  event BackendAdminAdded(address indexed account);
  event BackendAdminRemoved(address indexed account);
}
