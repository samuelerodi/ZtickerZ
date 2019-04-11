pragma solidity ^0.5.2;

import '../interface/IZtickyStake.sol';

import '../interface/IZtickyCoinZ.sol';
import '../backend/Backend.sol';
import '../utils/HasNoEther.sol';
import '../utils/DestructibleZCZ.sol';
import "../utils/SafeMath.sol";
import '../ERC900/ERC900.sol';
import '../ERC20/ERC20.sol';

/**
 * @title ZtickyStake
 * @dev The ZtickyStake contract is a backend ERC900 contract used as storage for staking features.
 * It doesn't supports history and implements an interface callable exclusively from the logic contract
 */
contract ZtickyStake is IZtickyStake, ERC900, DestructibleZCZ, HasNoEther {

  using SafeMath for uint256;

  uint256 public vestingTime = 0;
  uint256 public totalShares = 1 ether;

  struct ShareContract {
    uint256 stakedValue;
    uint256 lastUpdated;
  }

  ShareContract public total;
  mapping (address => ShareContract) public shareHolders;

  constructor(address _zcz) ERC900(ERC20(_zcz)) DestructibleZCZ(IZtickyCoinZ(_zcz)) public {}

  function calculateCurrentStakedValueFromPreviousState(uint256 _previousStakedValue, uint256 _previousStakeAmount, uint256 _updatedAt)
  internal
  view
  returns (uint256 _stakedValue)
  {
    uint256 _delta = block.timestamp.sub(_updatedAt);
    _stakedValue = _previousStakedValue.add(_delta.mul(_previousStakeAmount));
  }

  function calculateCurrentStakedValueFromHistory(uint256[] memory blockTimestamps, uint256[] memory amounts, uint256 _vestingTime)
  internal
  view
  returns (uint256 _stakedValue, uint256 _maturedTokens)
  {
    for (uint256 i = 0; i < blockTimestamps.length; i++) {
      if (block.timestamp.sub(blockTimestamps[i]) < _vestingTime) continue;
      _maturedTokens = _maturedTokens.add(amounts[i]);
      _stakedValue = _stakedValue.add(calculateCurrentStakedValueFromPreviousState(0, amounts[i], blockTimestamps[i]));
    }
  }

  function calculateShares(uint256 _stakedValue, uint256 _totalStakedValue)
  internal
  view
  returns (uint256)
  {
    return _stakedValue.mul(totalShares).div(_totalStakedValue);
  }

  function updateStakedValue()
  internal
  {
    total.stakedValue = totalStakedValue();
    total.lastUpdated = block.timestamp;
  }

  function updateStakedValueOf(address _shareHolder)
  internal
  {
    shareHolders[_shareHolder].stakedValue = stakedValueOf(_shareHolder);
    shareHolders[_shareHolder].lastUpdated = block.timestamp;
  }

  function createStake(address _stakedBy, address _stakeFor, uint256 _amount)
  internal
  returns (uint256 , uint256)
  {
    updateStakedValue();
    updateStakedValueOf(_stakeFor);
    return ERC900.createStake(_stakedBy, _stakeFor, _amount);
  }

  function withdrawStake(address _stakedBy, address _stakeFor, uint256 _amount)
  internal
  returns(uint256[] memory blockTimestamps, uint256[] memory amounts)
  {
    updateStakedValue();
    updateStakedValueOf(_stakeFor);
    (blockTimestamps, amounts) = ERC900.withdrawStake(_stakedBy, _stakeFor, _amount);
    uint256 _unstakedShare = 0;
    uint256 n = block.timestamp;
    for (uint256 i = 0; i < amounts.length; i++) {
      uint256 _delta = n.sub(blockTimestamps[i]);
      _unstakedShare = _unstakedShare.add(_delta.mul(amounts[i]));
    }
    shareHolders[_stakeFor].stakedValue = shareHolders[_stakeFor].stakedValue.sub(_unstakedShare);
    total.stakedValue = total.stakedValue.sub(_unstakedShare);
  }

  function isZStake()
  public
  pure
  returns(bool)
  {
    return true;
  }

  function totalStakedValue()
  public
  view
  returns (uint256)
  {
    return calculateCurrentStakedValueFromPreviousState(total.stakedValue, ERC900.totalStaked(), total.lastUpdated);
  }

  function stakedValueOf(address _shareHolder)
  public
  view
  returns (uint256)
  {
    ShareContract storage s = shareHolders[_shareHolder];
    return calculateCurrentStakedValueFromPreviousState(s.stakedValue, ERC900.totalStakedFor(_shareHolder), s.lastUpdated);
  }

  function vestedSharesOf(address _shareHolder)
  public
  view
  returns (uint256)
  {
    return calculateShares(stakedValueOf(_shareHolder), totalStakedValue());
  }

  function sharesOf(address _stakeFor)
  public
  view
  returns(uint256) {
    return sharesByFor(_stakeFor, _stakeFor);
  }

  function sharesByFor(address _stakedBy, address _stakeFor)
  public
  view
  returns(uint256) {
    (uint256[] memory blockTimestamps, uint256[] memory amounts) = ERC900.getActiveStakesBy(_stakedBy, _stakeFor);
    (uint256 _stakedValue, ) = calculateCurrentStakedValueFromHistory(blockTimestamps, amounts, vestingTime);
    return calculateShares(_stakedValue, totalStakedValue());
  }

  function maturedTokensOf(address _stakeFor)
  public
  view
  returns(uint256) {
    return maturedTokensByFor(_stakeFor, _stakeFor);
  }

  function maturedTokensByFor(address _stakedBy, address _stakeFor)
  public
  view
  returns(uint256) {
    (uint256[] memory blockTimestamps, uint256[] memory amounts) = ERC900.getActiveStakesBy(_stakedBy, _stakeFor);
    (, uint256 _maturedTokens) = calculateCurrentStakedValueFromHistory(blockTimestamps, amounts, vestingTime);
    return _maturedTokens;
  }

  function changeVestingTime(uint256 _newVestingTime)
  onlyBackendAdmin
  public
  returns (bool)
  {
    vestingTime = _newVestingTime;
    return true;
  }

  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the user
   * @notice MUST trigger Staked event
   * @param _amount uint256 the amount of tokens to stake
   */
  function authorizedStakeFor(address _stakeFor, uint256 _amount)
  onlyFrontend
  whenNotPaused
  public
  returns (bool)
  {
    createStake(tx.origin, _stakeFor, _amount);
    return true;
  }

  /**
  * @notice Unstakes a certain amount of tokens, this SHOULD return the given amount of tokens to the user, if unstaking is currently not possible the function MUST revert
  * @notice MUST trigger Unstaked event
  * @dev Users can only unstake starting from their oldest active stake. Upon releasing that stake, the tokens will be
  *  transferred back to their account, and their stakeIndex will increment to the next active stake.
  * @param _amount uint256 the amount of tokens to unstake
  */
  function authorizedUnstakeFor(address _stakeFor, uint256 _amount)
  onlyFrontend
  whenNotPaused
  public
  returns (uint256)
  {
    uint256 _totalStakedValue = totalStakedValue();
    (uint256[] memory blockTimestamps, uint256[] memory amounts) =  withdrawStake(tx.origin, _stakeFor, _amount);
    (uint256 _stakedValue,) = calculateCurrentStakedValueFromHistory(blockTimestamps, amounts, vestingTime);
    return calculateShares(_stakedValue, _totalStakedValue);
  }

  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the user
   * @notice MUST trigger Staked event
   * @param _amount uint256 the amount of tokens to stake
   */
  function authorizedStake(uint256 _amount)
  public
  returns (bool)
  {
    return authorizedStakeFor(tx.origin, _amount);
  }


  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the user
   * @notice MUST trigger Staked event
   * @param _amount uint256 the amount of tokens to stake
   */
  function authorizedUnstake(uint256 _amount)
  public
  returns (uint256)
  {
    return authorizedUnstakeFor(tx.origin, _amount);
  }
}
