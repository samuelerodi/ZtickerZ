pragma solidity ^0.5.2;

import '../interface/IZtickyStake.sol';
import '../interface/IZtickyCoinZ.sol';

interface IZtickerZ {
  /* Frontend */
  function isBackendConfigured() external view returns(bool);
  function changeZStakeContract(address _newAddress) external returns(bool);
  function changeZCZContract(address _newAddress) external returns(bool);
  function ZCZ() external view returns(IZtickyCoinZ);
  function ZStake() external view returns(IZtickyStake);

  /* ZtickerZ */
  function mint(address _to, uint256 _amount) external returns (bool);
  function stake(uint256 value) external returns (bool);
  function unstake(uint256 value) external returns (bool);
}
