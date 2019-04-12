pragma solidity ^0.5.2;

interface IZtickyBank {

  //ZtickyBank
  function isZBank() external pure returns(bool);
  function totalBalance() external view returns (uint256, uint256);
  function outstandingDividendsPerShare() external view returns (uint256, uint256);
  function outstandingDividendsFor(uint256 shares) external view returns (uint256, uint256);
  function payout(address payable to, uint256 shares) external returns (bool);
  function () external payable;


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
  //Destructible
  function destroy() external;
  function destroyAndSend(address payable _recipient) external;


  event Withdraw(address indexed by, uint256 eth, uint256 zcz);
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
