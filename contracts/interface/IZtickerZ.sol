pragma solidity ^0.5.2;

import '../interface/IZtickyStake.sol';
import '../interface/IZtickyCoinZ.sol';
import '../interface/IZtickyBank.sol';

interface IZtickerZ {
  /* ZtickerZ */
  function expectedDividends(address _stakeFor) external view returns (uint256, uint256);
  function expectedDividendsFor(address _stakedBy, address _stakeFor) external view returns (uint256, uint256);
  function mint(address to) external returns (bool);
  function payDividends() external returns (bool);
  function stake(uint256 value) external returns (bool);
  function unstake(uint256 value) external returns (bool);
  function stakeFor(address stakedFor, uint256 value) external returns (bool);
  function unstakeFor(address payable stakedFor, uint256 value) external returns (bool);
  function claimDividendsAndRestake() external returns (bool);
  function claimDividendsAndRestakeFor(address payable stakedFor) external returns (bool);

  /* Frontend */
  function isBackendConfigured() external view returns(bool);
  function changeZCZContract(address newAddress) external returns(bool);
  function changeZStakeContract(address newAddress) external returns(bool);
  function changeZBankContract(address payable newAddress) external returns(bool);
  function ZCZ() external view returns(IZtickyCoinZ);
  function ZStake() external view returns(IZtickyStake);
  function ZBank() external view returns(IZtickyBank);

  /* FrontendAdmin */
  function isFrontendAdmin(address account) external view returns (bool);
  function addFrontendAdmin(address account) external;
  function removeFrontendAdmin(address account) external;
  function renounceFrontendAdmin() external;

  /* Destructible */
  function destroy() external;
  function destroyAndSend(address payable _recipient) external;
}
