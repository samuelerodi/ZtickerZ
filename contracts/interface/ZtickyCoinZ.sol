pragma solidity ^0.5.2;

interface ZtickyCoinZInterface {
  //BASE
  function mint(address _to, uint256 _amount) external returns(bool);
  function burn(uint256 _value) external returns(bool);
  function frontendApprove(address spender, uint256 value) external returns (bool);
  //ERC20
  function totalSupply() external view returns (uint256);
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  //ERC20Detailed
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  //ERC20Pausable
  function transfer(address to, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function increaseAllowance(address spender, uint addedValue) external returns (bool success);
  function decreaseAllowance(address spender, uint subtractedValue) external returns (bool success);
  //Pausable
  function paused() external view returns (bool);
  function pause() external;
  function unpause() external;
  //PauserRole
  function isPauser(address account) external view returns (bool);
  function addPauser(address account) external;
  function renouncePauser() external;
  //Ownable
  function owner() external view returns (address);
  function isOwner() external view returns (bool);
  function transferOwnership(address newOwner) external;
  //Backend
  function isFrontend(address account) external view returns (bool);
  function addFrontend(address account) external;
  function removeFrontend(address account) external;
  //BackendAdmin
  function isBackendAdmin(address account) external view returns (bool);
  function addBackendAdmin(address account) external;
  function removeBackendAdmin(address account) external;
  function renounceBackendAdmin() external;
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
