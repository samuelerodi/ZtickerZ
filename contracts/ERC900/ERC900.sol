/* solium-disable security/no-block-members */
pragma solidity ^0.5.2;

import "../ERC20/ERC20.sol";
import "../utils/SafeMath.sol";
import "../utils/Arrays.sol";
import "../utils/Pausable.sol";
import "../utils/Math.sol";

import "../ERC900/IERC900.sol";


/**
 * @title ERC900 Simple Staking Interface basic implementation
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-900.md
 */
contract ERC900 is IERC900, Pausable {
  // @TODO: deploy this separately so we don't have to deploy it multiple times for each contract
  using SafeMath for uint256;
  using Arrays for uint256[];

  // Token used for staking
  ERC20 public ERC20tokenContract;

  // To save on gas, rather than create a separate mapping for totalStakedFor & stakes,
  //  both data structures are stored in a single mapping for a given addresses.
  //
  // It's possible to have a non-existing stakes, but have tokens in totalStakedFor
  //  if other users are staking on behalf of a given address.
  mapping (address => StakeContract) public stakeHolders;

  // Struct for personal stakes (i.e., stakes made by this address)
  // blockNumber - block number when the stake has been created
  // amount - the amount of tokens in the stake
  // stakedFor - the address the stake was staked for
  struct Stake {
    uint256 blockNumber;
    uint256 amount;
    uint256 unstaked;
  }

  // Struct for HistoryRef stakes (i.e., stakes made for this address)
  // stakedBy - the address owner of the stake
  // idx - the index where the stake is stored
  struct HistoryRef {
    address stakedBy;
    uint256 idx;
  }

  struct StakingStructure {
    uint256 stakeIndex;
    Stake[] stakes;
  }

  // Struct for all stake metadata at a particular address
  // total - the number of tokens staked for this address
  // fors - a mapping of StakedFor made by this address .
  // stakes - array list of stakes made for this address
  struct StakeContract {
    uint256 total;
    HistoryRef[] personalStakingHistory;
    mapping (address => StakingStructure) fors;
  }

  /**
   * @dev Constructor function
   * @param _ERC20tokenContract address The address of the token contract used for staking
   */
  constructor(ERC20 _ERC20tokenContract) public {
    require(address(_ERC20tokenContract) != address(0));
    ERC20tokenContract = _ERC20tokenContract;
  }

  /**
   * @dev Modifier that checks that this contract can transfer tokens from the
   *  balance in the ERC20tokenContract contract for the given address.
   * @dev This modifier also transfers the tokens.
   * @param _address address to transfer tokens from
   * @param _amount uint256 the number of tokens
   */
  modifier canStake(address _address, uint256 _amount) {
    require(_amount!=0, "Amount to be staked cannot be 0.");
    require(ERC20tokenContract.transferFrom(_address, address(this), _amount),"Stake required");
    _;
  }



  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the user
   * @notice MUST trigger Staked event
   * @param _amount uint256 the amount of tokens to stake
   */
  function stake(uint256 _amount) public {
    createStake(msg.sender, msg.sender, _amount);
  }

  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the caller
   * @notice MUST trigger Staked event
   * @param _stakeFor address the address the tokens are staked for
   * @param _amount uint256 the amount of tokens to stake
   */
  function stakeFor(address _stakeFor, uint256 _amount) public {
    createStake(msg.sender, _stakeFor, _amount);
  }

  /**
   * @notice Unstakes a certain amount of tokens, this SHOULD return the given amount of tokens to the user, if unstaking is currently not possible the function MUST revert
   * @notice MUST trigger Unstaked event
   * @dev Users can only unstake starting from their oldest active stake. Upon releasing that stake, the tokens will be
   *  transferred back to their account, and their stakeIndex will increment to the next active stake.
   * @param _amount uint256 the amount of tokens to unstake
   */
  function unstake(uint256 _amount) public {
    withdrawStake(msg.sender, msg.sender, _amount);
  }

  /**
   * @notice Unstakes a certain amount of tokens for a given user, this SHOULD return the given amount of tokens to the owner
   * @notice MUST trigger Unstaked event
   * @dev Users can only unstake starting from the oldest active stake. Upon releasing that stake, the tokens will be
   *  transferred back to their owner, and their stakeIndex will increment to the next active stake.
   * @param _stakeFor address the user the tokens are staked for
   * @param _amount uint256 the amount of tokens to unstake
   */
  function unstakeFor(address _stakeFor, uint256 _amount) public {
    withdrawStake(msg.sender, _stakeFor, _amount);
  }

  /**
   * @notice Returns the current total of tokens staked for an address
   * @param _address address The address to query
   * @return uint256 The number of tokens staked for the given address
   */
  function totalStakedFor(address _address) public view returns (uint256) {
    return stakeHolders[_address].total;
  }

  /**
   * @notice Returns the current total of tokens staked
   * @return uint256 The number of tokens staked in the contract
   */
  function totalStaked() public view returns (uint256) {
    return ERC20tokenContract.balanceOf(address(this));
  }

  /**
   * @notice Address of the token being used by the staking interface
   * @return address The address of the ERC20 token used for staking
   */
  function token() public view returns (address) {
    return address(ERC20tokenContract);
  }

  /**
   * @notice MUST return true if the optional history functions are implemented, otherwise false
   * @dev Since we don't implement the optional interface, this always returns false
   * @return bool Whether or not the optional history functions are implemented
   */
  function supportsHistory() public pure returns (bool) {
    return false;
  }

  /**
   * @dev Helper function to get specific properties of active stakes created by an address for the same address
   * @param _stakeFor address The address for which it is being staked
   * @return (uint256[], uint256[])
   *  timestamps array, amounts array
   */
  function getActiveStakesFor(address _stakeFor)
    view
    public
    returns(uint256[] memory blockNumbers, uint256[] memory amounts)
  {
    return getActiveStakesBy(_stakeFor, _stakeFor);
  }

  /**
   * @dev Helper function to get specific properties of active stakes created by an address for another address
   * @param _stakedBy address The address that initiated the stake
   * @param _stakeFor address The address for which it is being staked
   * @return (uint256[], uint256[])
   *  timestamps array, amounts array
   */
  function getActiveStakesBy(address _stakedBy, address _stakeFor)
    view
    public
    returns(uint256[] memory blockNumbers, uint256[] memory amounts)
  {
    StakingStructure storage _ss = stakeHolders[_stakedBy].fors[_stakeFor];
    uint256 _size = _ss.stakes.length.sub(_ss.stakeIndex);
    blockNumbers = new uint256[](_size);
    amounts = new uint256[](_size);

    for (uint256 i = 0; i < _size; i++) {
      Stake storage _s = _ss.stakes[_ss.stakeIndex.add(i)];
      blockNumbers[i] = _s.blockNumber;
      amounts[i] = _s.amount.sub(_s.unstaked);
    }
    return (blockNumbers, amounts);
  }

  /**
   * @dev Helper function to get specific properties of all of the personal stakes created by an address
   * @param _stakeFor address The address to query
   * @return (uint256[], uint256[], uint256[], address[])
   *  timestamps array, amounts array, unstaked array, stakedFor array
   */
  function getStakingHistoryOf(address _stakeFor)
    view
    public
    returns(uint256[] memory blockNumbers, uint256[] memory amounts, uint256[] memory unstaked, address[] memory stakedBy)
  {
    StakeContract storage _sc = stakeHolders[_stakeFor];
    uint256 _size = _sc.personalStakingHistory.length;
    blockNumbers = new uint256[](_size);
    amounts = new uint256[](_size);
    unstaked = new uint256[](_size);
    stakedBy = new address[](_size);

    for (uint256 i = 0; i < _sc.personalStakingHistory.length; i++) {
      HistoryRef memory _h = _sc.personalStakingHistory[i];
      Stake memory _s = stakeHolders[_h.stakedBy].fors[_stakeFor].stakes[_h.idx];
      blockNumbers[i] = _s.blockNumber;
      amounts[i] = _s.amount;
      unstaked[i] = _s.unstaked;
      stakedBy[i] = _sc.personalStakingHistory[i].stakedBy;
    }
  }

  /**
   * @dev Helper function to create stakes for a given address
   * @param _stakedBy address The sender requesting the stake
   * @param _stakeFor address The address the stake is being created for
   * @param _amount uint256 The number of tokens being staked
   */
  function createStake(address _stakedBy, address _stakeFor, uint256 _amount)
    internal
    whenNotPaused
    canStake(_stakedBy, _amount)
    returns (uint256 , uint256)
  {
    stakeHolders[_stakeFor].total = stakeHolders[_stakeFor].total.add(_amount);
    Stake memory s = Stake(block.number, _amount, 0);
    uint256 _l = stakeHolders[_stakedBy].fors[_stakeFor].stakes.push(s);
    HistoryRef memory _h = HistoryRef(_stakedBy, _l-1);
    stakeHolders[_stakeFor].personalStakingHistory.push(_h);
    emit Staked(_stakeFor, s.amount, totalStakedFor(_stakeFor), _stakedBy);
    return (s.blockNumber, s.amount);
  }

  /**
   * @dev Helper function to withdraw stakes back to the original _stakedBy
   * @param _stakedBy address The sender that created the stake
   * @param _stakeFor address The address for which tokens are being unstaken
   * @param _amount uint256 The amount to withdraw. Any exceeding amount will be mapped to the maximum available stake amount.
   */
  function withdrawStake(address _stakedBy, address _stakeFor, uint256 _amount)
    internal
    whenNotPaused
    returns(uint256[] memory blockNumbers, uint256[] memory amounts)
  {
    StakingStructure storage ss = stakeHolders[_stakedBy].fors[_stakeFor];
    uint256 _totalUnstaked = 0;
    uint256 l = 0;
    blockNumbers = new uint256[](ss.stakes.length);
    amounts = new uint256[](ss.stakes.length);
    while(_amount > 0 && ss.stakeIndex < ss.stakes.length) {
      Stake storage s = ss.stakes[ss.stakeIndex];
      uint256 _remainder = s.amount.sub(s.unstaked);
      uint256 _unstake = Math.min(_amount, _remainder);
      _amount = _amount.sub(_unstake);
      s.unstaked = s.unstaked.add(_unstake);
      _totalUnstaked = _totalUnstaked.add(_unstake);
      stakeHolders[_stakeFor].total = stakeHolders[_stakeFor].total.sub(_unstake);
      // Add safe check in case of contract vulnerability
      require(s.amount>=s.unstaked, "Inconsistent staking state.");
      if (s.amount == s.unstaked) ss.stakeIndex++;
      emit Unstaked(_stakeFor, _unstake, totalStakedFor(_stakeFor), _stakedBy);
      blockNumbers[l] = s.blockNumber;
      amounts[l] = _unstake;
      l++;
    }
    // Transfer the staked tokens from this contract back to the sender
    // Notice that we are using transfer instead of transferFrom here.
    if (_totalUnstaked != 0) require(ERC20tokenContract.transfer(_stakedBy, _totalUnstaked), "Unable to withdraw stake");
    return  (blockNumbers.subarray(0,l), amounts.subarray(0,l));
  }
}
