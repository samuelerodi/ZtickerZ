pragma solidity ^0.5.2;

import '../interface/IZtickyStake.sol';

import '../backend/Backend.sol';
import '../utils/HasNoEther.sol';
import "../utils/SafeMath.sol";
import '../ERC900/ERC900.sol';
import '../ERC20/ERC20.sol';

/**
 * @title ZtickyStake
 * @dev The ZtickyStake contract is a backend ERC900 contract used as storage for staking features.
 * It doesn't supports history and implements an interface callable exclusively from the logic contract
 */
contract ZtickyStake is IZtickyStake, ERC900, HasNoEther, Backend {

  using SafeMath for uint256;

  uint256 totalShare = 0;
  uint256 totalStake = 0;
  uint256 lastUpdated = 0;

  constructor(address _zcz) ERC900(ERC20(_zcz)) public {}

  function getShare(uint256 _previousShare, uint256 _previousStake, uint256 _updatedAt)
  internal
  returns (uint256 _totalShare)
  {
    uint256 _delta = block.number.sub(_updatedAt);
    uint256 _totalShare = totalShare + delta.mul(totalStake);
  }

  function createStake(address _sender, address _stakeFor, uint256 _amount, bytes memory _data)
  internal
  {
    totalShare = getShare(totalShare, totalStake, lastUpdated);
    lastUpdated = block.number;
    ( , uint256 _stakedAmount, ) = ERC900.createStake(_sender, _stakeFor, _amount, _data);
    totalStake = totalStake.add(_stakedAmount);
  }

  function withdrawStake(address _sender, uint256 _amount, bytes memory _data)
  internal
  {
    totalShare = getShare(totalShare, totalStake, lastUpdated);
    lastUpdated = block.number;
    (uint256[] memory blockNumbers, uint256[] memory amounts, address[] memory stakeFors) = ERC900.withdrawStake(_sender, _amount, _data);
    uint256 _unstakedShare = 0;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalStake = totalStake.sub(amounts[i]);
      _unstakedShare = _unstakedShare + block.number.sub(blockNumbers[i]).mul(amounts[i])
    }
    totalShare = totalShare.sub(_unstakedShare);
  }
}
