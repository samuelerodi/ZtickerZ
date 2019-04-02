pragma solidity ^0.5.2;

interface IZtickyStake {
  //Backend
  function isBackend() external pure returns (bool);
  function isFrontend(address account) external view returns (bool);
  function addFrontend(address account) external;
  function removeFrontend(address account) external;
  //BackendAdmin
  function isBackendAdmin(address account) external view returns (bool);
  function addBackendAdmin(address account) external;
  function removeBackendAdmin(address account) external;
  function renounceBackendAdmin() external;
  //Pausable
  function paused() external view returns (bool);
  function pause() external;
  function unpause() external;
  //PauserRole
  function isPauser(address account) external view returns (bool);
  function addPauser(address account) external;
  function renouncePauser() external;
  //Ownable
  function owner() external view returns (address payable);
  function isOwner() external view returns (bool);
  function transferOwnership(address payable newOwner) external;
  //HasNoEther
  function reclaimEther() external;
  function() external;
  //Destructible
  function destroy() external;
  function destroyAndSend(address payable _recipient) external;

  //ERC900
  function stake(uint256 amount, bytes calldata data) external;
  function stakeFor(address user, uint256 amount, bytes calldata data) external;
  function unstake(uint256 amount, bytes calldata data) external;
  function unstakeFor(address user, uint256 amount, bytes calldata data) external;
  function totalStakedFor(address addr) external view returns (uint256);
  function totalStaked() external view returns (uint256);
  function token() external view returns (address);
  function supportsHistory() external pure returns (bool);

  //ZtickyStake
  function totalShares() external view returns (uint256);
  function sharesOf(address _shareHolder) external view returns (uint256);
  function shareRatioOf(address _shareHolder) external view returns (uint256);
  function authorizedStake(uint256 _amount, bytes calldata _data) external returns (bool);
  function authorizedUnstake(uint256 _amount, bytes calldata _data) external returns (uint256);
  function authorizedStakeFor(address _stakeFor, uint256 _amount, bytes calldata _data) external returns (bool);
  function authorizedUnstakeFor(address _stakeFor, uint256 _amount, bytes calldata _data) external returns (uint256);
  function changeMinimumLockTime(uint256 _newMinimumLockTime) external returns (bool);



  event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
  event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);
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
