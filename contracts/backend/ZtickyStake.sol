pragma solidity ^0.5.2;

import '../interface/IZtickyStake.sol';

import '../backend/Backend.sol';
import '../utils/HasNoEther.sol';
import '../utils/HasZCZ.sol';
import '../utils/DestructibleZCZ.sol';
import "../utils/SafeMath.sol";
import '../ERC900/ERC900.sol';
import '../ERC20/ERC20.sol';

/**
 * @title ZtickyStake
 * @author Samuele Rodi (a.k.a. Sam Fisherman)
 * @notice The ZtickyStake contract is a backend ERC900 contract used as storage for staking features.
 * This contract aims to let token stakeholders to mature outstanding shares.
 * In this implementations, it does not exist any predefined structure of shareholders, instead shareholders
 * owns a ratio of the total shares in a dinamic fashion based on their staked value over the total.
 * The staked value of a user is constantly changing as it consists in the intregral of the currently active staked amount
 * over the time in which the stake has been active.
 * The total staked value is the sum of the staked value of all of its users with an ongoing stake.
 * The staked value of a user is the parameter which determines the shares ratio of a given user over the total.
 * However, shares by a user are accumulated in the form of vested shares, which means that they are not redeemable
 * as outstanding shares unless a minimum vesting time has effectively passed from the begin of the staking,
 * (i.e. a time threshold necessary to let the tokens locked into a staking contract to mature some shares).
 */
contract ZtickyStake is IZtickyStake, HasZCZ, ERC900, DestructibleZCZ, HasNoEther, Backend {

  using SafeMath for uint256;

  /**
   * @dev The vesting time is controlled by the BackendAdmin and represent the minimum
   * staking time to let staked tokens mature outstanding shares.
   */
  uint256 public vestingTime = 0;
  /**
   * @dev The number of outstanding shares as per standard
   */
  uint256 public totalShares = 1 ether;

  /**
   * @dev Given the fact that the total staked amount is a step function over time, the staked value can
   * be thus calculated in a linear fashion starting from the latest update to the total staked amount (the last staking or unstaking operation).
   * In a similar fashion also the individual staked value of users can be evaluated using a linearized form of the current staked amount and
   * a reference to the last updated staked value.
   * The ShareContract struct serves to store the latest reference to the staked value and its corresponding time of latest update
   */
  struct ShareContract {
    uint256 stakedValue;
    uint256 lastUpdated;
  }

  /**
   * @dev The data structure which stores the global staked value
   */
  ShareContract public total;

  /**
   * @dev The address mapping which stores the staked value of currently active stakeholders
   */
  mapping (address => ShareContract) public shareHolders;

  constructor(address _zcz) ERC900(ERC20(_zcz))  public {
    HasZCZ._setZCZ(_zcz);
  }

  /**
   * @dev Helper function used to calculated the current staked value starting from a previous state
   * in the hypotesis of no intermediate staking updates
   * @param _previousStakedValue The latest updated staked value
   * @param _previousStakeAmount The current token staked amount
   * @param _updatedAt The timestamp of the latest update of the staked value
   */
  function calculateCurrentStakedValueFromPreviousState(uint256 _previousStakedValue, uint256 _previousStakeAmount, uint256 _updatedAt)
    internal
    view
    returns (uint256 _stakedValue)
  {
    uint256 _delta = block.timestamp.sub(_updatedAt);
    _stakedValue = _previousStakedValue.add(_delta.mul(_previousStakeAmount));
  }

  /**
   * @dev Helper function used to calculate the accumulated staked value over an entire set of history states
   * representing active ongoing token stakes.
   * @param blockTimestamps An array of timestamps specifying the date of creation of the staking instance
   * @param amounts An array specifying the active staked amount of tokens for the corresponding specific date
   * @param _vestingTime The vesting time considered used for the evaluation of matured tokens
   * @return _stakedValue The calculated (outstanding) staked value
   * @return _maturedTokens The amount of tokens that have matured outstanding shares
   */
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

  /**
   * @dev Helper function used to derive an address' shares ratio from the total staked value.
   * @param _stakedValue The staked value owner of the shares ratio
   * @param _totalStakedValue The global staked value
   * @return uint256 The shares ratio expressed as a number from 0 to 1 ether
   */
  function calculateShares(uint256 _stakedValue, uint256 _totalStakedValue)
    internal
    view
    returns (uint256)
  {
    return _stakedValue.mul(totalShares).div(_totalStakedValue);
  }

  /**
   * @dev Helper function used to update the global staked value reference.
   */
  function updateStakedValue()
    internal
  {
    total.stakedValue = totalStakedValue();
    total.lastUpdated = block.timestamp;
  }

  /**
   * @dev Helper function used to update the staked value reference for a specific address.
   * @param _shareHolder Address of the beneficiary of the staking and shareholder
   */
  function updateStakedValueOf(address _shareHolder)
    internal
  {
    shareHolders[_shareHolder].stakedValue = stakedValueOf(_shareHolder);
    shareHolders[_shareHolder].lastUpdated = block.timestamp;
  }

  /**
   * @dev Helper middleware responsible for creating a staking instance as per ERC900 implementation and keeps the staked value references up to date.
   * @param _stakedBy Owner of the stake
   * @param _stakeFor Beneficiary of the stake
   * @param _amount Amount of the stake
   */
  function createStake(address _stakedBy, address _stakeFor, uint256 _amount)
    internal
    returns (uint256 , uint256)
  {
    updateStakedValue();
    updateStakedValueOf(_stakeFor);
    return ERC900.createStake(_stakedBy, _stakeFor, _amount);
  }

  /**
   * @dev Helper middleware responsible for withdrawing a staking instance as per ERC900 implementation and keeps the staked value references up to date.
   * @param _stakedBy Owner of the stake
   * @param _stakeFor Beneficiary of the stake
   * @param _amount Amount to unstake
   */
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


  /**
   * @notice Function that confirms that this contract implements a ZtickyStake interface
   * @return true.
   */
  function isZStake()
    public
    pure
    returns(bool)
  {
    return true;
  }

  /**
   * @notice Returns the global current active staked value for all addresses
   * @return uint256 The staked value.
   */
  function totalStakedValue()
    public
    view
    returns (uint256)
  {
    return calculateCurrentStakedValueFromPreviousState(total.stakedValue, ERC900.totalStaked(), total.lastUpdated);
  }

  /**
   * @notice Returns the current active staked value for a given address
   * @param _shareHolder The shareholder beneficiary of the stake
   * @return uint256 The staked value.
   */
  function stakedValueOf(address _shareHolder)
    public
    view
    returns (uint256)
  {
    ShareContract storage s = shareHolders[_shareHolder];
    return calculateCurrentStakedValueFromPreviousState(s.stakedValue, ERC900.totalStakedFor(_shareHolder), s.lastUpdated);
  }

  /**
   * @notice Returns the vested shares ratio for a given address (i.e. the total amount of shares
   * ratio accumulated comprising of both maturing shares and redeemable outstanding shares)
   * @param _shareHolder The shareholder beneficiary of the stake
   * @return uint256 The vested shares ratio.
   */
  function vestedSharesOf(address _shareHolder)
    public
    view
    returns (uint256)
  {
    return calculateShares(stakedValueOf(_shareHolder), totalStakedValue());
  }

  /**
   * @notice Returns the outstanding shares ratio (i.e. only the amount of redeemable outstanding shares,
   * matured vested shares) of an active ongoing stakes made by a stake owner and for a specific beneficiary
   * @param _stakedBy The owner of the active stake
   * @param _stakeFor The beneficiary of the stake
   * @return uint256 The outstanding shares ratio.
   */
  function sharesByFor(address _stakedBy, address _stakeFor)
    public
    view
    returns(uint256)
  {
    (uint256[] memory blockTimestamps, uint256[] memory amounts) = ERC900.getActiveStakesBy(_stakedBy, _stakeFor);
    (uint256 _stakedValue, ) = calculateCurrentStakedValueFromHistory(blockTimestamps, amounts, vestingTime);
    return calculateShares(_stakedValue, totalStakedValue());
  }

  /**
   * @notice Returns the outstanding shares ratio (i.e. only the amount of redeemable outstanding shares,
   * matured vested shares) of an active ongoing stakes made by an address for itself
   * @param _stakeFor The beneficiary of the stake
   * @return uint256 The outstanding shares ratio.
   */
  function sharesOf(address _stakeFor)
    public
    view
    returns(uint256)
  {
    return sharesByFor(_stakeFor, _stakeFor);
  }

  /**
   * @notice Returns the amount of matured staked tokens (i.e. tokens that have passed the minimum vesting time threshold)
   * inside an active ongoing stake made by a stake owner for a specific beneficiary
   * @param _stakedBy The owner of the stake
   * @param _stakeFor The beneficiary of the stake
   * @return uint256 The amount of matured staked tokens.
   */
  function maturedTokensByFor(address _stakedBy, address _stakeFor)
    public
    view
    returns(uint256)
  {
    (uint256[] memory blockTimestamps, uint256[] memory amounts) = ERC900.getActiveStakesBy(_stakedBy, _stakeFor);
    (, uint256 _maturedTokens) = calculateCurrentStakedValueFromHistory(blockTimestamps, amounts, vestingTime);
    return _maturedTokens;
  }

  /**
   * @notice Returns the amount of matured staked tokens (i.e. tokens that have passed the minimum vesting time threshold)
   * inside an active ongoing stake made by a an address for itself
   * @param _stakeFor The beneficiary of the stake
   * @return uint256 The amount of matured staked tokens.
   */
  function maturedTokensOf(address _stakeFor)
    public
    view
    returns(uint256)
  {
    return maturedTokensByFor(_stakeFor, _stakeFor);
  }

  /**
   * @notice It changes the vesting time needed to mature outstanding shares.
   * This function is restricted only to backend admins.
   * @param _newVestingTime The new vesting time expressed in seconds
   * @return A boolean that indicates if the operation was successful.
   */
  function changeVestingTime(uint256 _newVestingTime)
    onlyBackendAdmin
    public
    returns (bool)
  {
    vestingTime = _newVestingTime;
    return true;
  }

  /**
   * @notice This function allows the frontend contract to perform a staking operation on behalf
   * of a specific address expressed as tx.origin for a specific beneficiary.
   * It requires of a preapproved token withdrawal.
   * @param _stakeFor the beneficiary of the stake
   * @param _amount the amount of tokens to stake
   * @return A boolean that indicates if the operation was successful.
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
   * @notice This function allows the frontend contract to perform an unstaking operations made by a stake owner
   * assigned to a specific beneficiary. During the unstake, it is calculated the corresponding outstanding
   * shares ratio that gets freed as a consequence of the unstake, and the corresponding staked value gets subtracted
   * from the total.
   * @param _stakeFor the beneficiary of the stake
   * @param _amount the amount of tokens to unstake
   * @return uint256 the shares ratio that gets freed
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
   * @notice This function allows the frontend contract to perform a staking operation on behalf
   * of a specific address for itself expressed as tx.origin.
   * It requires of a preapproved token withdrawal.
   * @param _amount the amount of tokens to stake
   * @return A boolean that indicates if the operation was successful.
   */
  function authorizedStake(uint256 _amount)
    public
    returns (bool)
  {
    return authorizedStakeFor(tx.origin, _amount);
  }


  /**
   * @notice This function allows the frontend contract to perform an unstaking operations made by an address for
   * itself. During the unstake, it is calculated the corresponding outstanding shares ratio that gets freed
   * as a consequence of the unstake, and the corresponding staked value gets subtracted from the total.
   * @param _amount the amount of tokens to unstake
   * @return uint256 the shares ratio that gets freed
   */
  function authorizedUnstake(uint256 _amount)
    public
    returns (uint256)
  {
    return authorizedUnstakeFor(tx.origin, _amount);
  }
}
