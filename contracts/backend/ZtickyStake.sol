pragma solidity ^0.5.2;

import '../interface/IZtickyStake.sol';

import '../backend/Backend.sol';
import '../utils/HasNoEther.sol';
import '../utils/Destructible.sol';
import "../utils/SafeMath.sol";
import '../ERC900/ERC900.sol';
import '../ERC20/ERC20.sol';

/**
 * @title ZtickyStake
 * @dev The ZtickyStake contract is a backend ERC900 contract used as storage for staking features.
 * It doesn't supports history and implements an interface callable exclusively from the logic contract
 */
contract ZtickyStake is IZtickyStake, ERC900, Destructible, HasNoEther, Backend {

  using SafeMath for uint256;

  uint256 public minimumLockTime = 0;

  struct ShareContract {
    uint256 outstandingShares;
    uint256 lastUpdated;
  }

  ShareContract public total;
  mapping (address => ShareContract) public shareHolders;

  constructor(address _zcz) ERC900(ERC20(_zcz)) public {}

  modifier emergencyUnstake(address _recipient) {
    require(ERC900.ERC20tokenContract.transfer(_recipient, ERC900.totalStaked()), "Transfer of staked locked tokens is required!");
    _;
  }

  function calculateCurrentSharesFromPreviousState(uint256 _previousShare, uint256 _previousStake, uint256 _updatedAt)
  internal
  view
  returns (uint256 _outstandingShares)
  {
    uint256 _delta = block.number.sub(_updatedAt);
    _outstandingShares = _previousShare.add(_delta.mul(_previousStake));
  }

  function calculateCurrentSharesFromHistory(uint256[] memory blockNumbers, uint256[] memory amounts, uint256 _minimumLockTime)
  internal
  view
  returns (uint256 _outstandingShares, uint256 _stakedTokenAtMaturity)
  {
    for (uint256 i = 0; i < blockNumbers.length; i++) {
      if (block.number.sub(blockNumbers[i]) < _minimumLockTime) continue;
      _stakedTokenAtMaturity = _stakedTokenAtMaturity.add(amounts[i]);
      _outstandingShares = _outstandingShares.add(calculateCurrentSharesFromPreviousState(0, amounts[i], blockNumbers[i]));
    }
  }

  function getShareRatio(uint256 _outstandingShares, uint256 _totalShares)
  internal
  pure
  returns (uint256)
  {
    return _outstandingShares.mul(1 ether).div(_totalShares);
  }

  function updateShares()
  internal
  {
    total.outstandingShares = totalShares();
    total.lastUpdated = block.number;
  }

  function updateSharesOf(address _shareHolder)
  internal
  {
    shareHolders[_shareHolder].outstandingShares = sharesOf(_shareHolder);
    shareHolders[_shareHolder].lastUpdated = block.number;
  }

  function createStake(address _stakedBy, address _stakeFor, uint256 _amount)
  internal
  returns (uint256 , uint256)
  {
    updateShares();
    updateSharesOf(_stakeFor);
    return ERC900.createStake(_stakedBy, _stakeFor, _amount);
  }

  function withdrawStake(address _stakedBy, address _stakeFor, uint256 _amount)
  internal
  returns(uint256[] memory blockNumbers, uint256[] memory amounts)
  {
    updateShares();
    updateSharesOf(_stakeFor);
    (blockNumbers, amounts) = ERC900.withdrawStake(_stakedBy, _stakeFor, _amount);
    uint256 _unstakedShare = 0;
    uint256 n = block.number;
    for (uint256 i = 0; i < amounts.length; i++) {
      uint256 _delta = n.sub(blockNumbers[i]);
      _unstakedShare = _unstakedShare.add(_delta.mul(amounts[i]));
    }
    shareHolders[_stakeFor].outstandingShares = shareHolders[_stakeFor].outstandingShares.sub(_unstakedShare);
    total.outstandingShares = total.outstandingShares.sub(_unstakedShare);
  }

  function isZStake()
  public
  pure
  returns(bool)
  {
    return true;
  }

  function totalShares()
  public
  view
  returns (uint256)
  {
    return calculateCurrentSharesFromPreviousState(total.outstandingShares, ERC900.totalStaked(), total.lastUpdated);
  }

  function sharesOf(address _shareHolder)
  public
  view
  returns (uint256)
  {
    ShareContract storage s = shareHolders[_shareHolder];
    return calculateCurrentSharesFromPreviousState(s.outstandingShares, ERC900.totalStakedFor(_shareHolder), s.lastUpdated);
  }

  function shareRatioOf(address _shareHolder)
  public
  view
  returns (uint256)
  {
    return getShareRatio(sharesOf(_shareHolder), totalShares());
  }

  function shareRatioAtMaturity(address _stakedBy, address _stakeFor)
  public
  view
  returns(uint256) {
    (uint256[] memory blockNumbers, uint256[] memory amounts) = ERC900.getActiveStakesBy(_stakedBy, _stakeFor);
    (uint256 _outstandingShares, ) = calculateCurrentSharesFromHistory(blockNumbers, amounts, minimumLockTime);
    return getShareRatio(_outstandingShares, totalShares());
  }

  function stakedTokenAtMaturity(address _stakedBy, address _stakeFor)
  public
  view
  returns(uint256) {
    (uint256[] memory blockNumbers, uint256[] memory amounts) = ERC900.getActiveStakesBy(_stakedBy, _stakeFor);
    (, uint256 _stakedTokenAtMaturity) = calculateCurrentSharesFromHistory(blockNumbers, amounts, minimumLockTime);
    return _stakedTokenAtMaturity;
  }

  function changeMinimumLockTime(uint256 _newMinimumLockTime)
  onlyBackendAdmin
  public
  returns (bool)
  {
    minimumLockTime = _newMinimumLockTime;
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
    uint256 _totalShares = totalShares();
    (uint256[] memory blockNumbers, uint256[] memory amounts) =  withdrawStake(tx.origin, _stakeFor, _amount);
    (uint256 _outstandingShares,) = calculateCurrentSharesFromHistory(blockNumbers, amounts, minimumLockTime);
    return getShareRatio(_outstandingShares, _totalShares);
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

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy()
  whenPaused
  onlyBackendAdmin
  emergencyUnstake(Ownable.owner())
  public
  {
    selfdestruct(Ownable.owner());
  }

  function destroyAndSend(address payable _recipient)
  whenPaused
  onlyOwner
  emergencyUnstake(_recipient)
  public
  {
    return Destructible.destroyAndSend(_recipient);
  }
}
