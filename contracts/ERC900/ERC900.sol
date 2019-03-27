/* solium-disable security/no-block-members */
pragma solidity ^0.5.2;

import "../ERC20/ERC20.sol";
import "../utils/SafeMath.sol";
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
  // stakeFor - the address the stake was staked for
  struct Stake {
    uint256 blockNumber;
    uint256 amount;
    uint256 unstaked;
    address stakeFor;
  }

  // Struct for all stake metadata at a particular address
  // total - the number of tokens staked for this address
  // stakeIndex - the index in the stakes array.
  // stakes - append only array of stakes made by this address
  struct StakeContract {
    uint256 total;
    uint256 stakeIndex;
    Stake[] stakes;
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
    require(ERC20tokenContract.transferFrom(_address, address(this), _amount),"Stake required");
    _;
  }



  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the user
   * @notice MUST trigger Staked event
   * @param _amount uint256 the amount of tokens to stake
   * @param _data bytes optional data to include in the Stake event
   */
  function stake(uint256 _amount, bytes memory _data) public {
    createStake(msg.sender, msg.sender, _amount, _data);
  }

  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the caller
   * @notice MUST trigger Staked event
   * @param _user address the address the tokens are staked for
   * @param _amount uint256 the amount of tokens to stake
   * @param _data bytes optional data to include in the Stake event
   */
  function stakeFor(address _user, uint256 _amount, bytes memory _data) public {
    createStake(msg.sender, _user, _amount,  _data);
  }

  /**
   * @notice Unstakes a certain amount of tokens, this SHOULD return the given amount of tokens to the user, if unstaking is currently not possible the function MUST revert
   * @notice MUST trigger Unstaked event
   * @dev Unstaking tokens is an atomic operation—either all of the tokens in a stake, or none of the tokens.
   * @dev Users can only unstake a single stake at a time, it is must be their oldest active stake. Upon releasing that stake, the tokens will be
   *  transferred back to their account, and their stakeIndex will increment to the next active stake.
   * @param _amount uint256 the amount of tokens to unstake
   * @param _data bytes optional data to include in the Unstake event
   */
  function unstake(uint256 _amount, bytes memory _data) public {
    withdrawStake(msg.sender, _amount, _data);
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
   * @dev Helper function to get specific properties of all of the personal stakes created by an address
   * @param _address address The address to query
   * @return (uint256[], uint256[], address[])
   *  timestamps array, amounts array, stakeFor array
   */
  function getPersonalStakes(address _address)
    view
    public
    returns(uint256[] memory, uint256[] memory, address[] memory)
  {
    StakeContract storage s = stakeHolders[_address];
    uint256 arraySize = s.stakes.length - s.stakeIndex;
    uint256[] memory blockNumbers = new uint256[](arraySize);
    uint256[] memory amounts = new uint256[](arraySize);
    address[] memory stakeFors = new address[](arraySize);

    for (uint256 i = s.stakeIndex; i < s.stakes.length; i++) {
      uint256 index = i - s.stakeIndex;
      blockNumbers[index] = s.stakes[i].blockNumber;
      amounts[index] = s.stakes[i].amount;
      stakeFors[index] = s.stakes[i].stakeFor;
    }

    return (blockNumbers, amounts, stakeFors);
  }

  /**
   * @dev Helper function to create stakes for a given address
   * @param _sender address The sender requesting the stake
   * @param _stakeFor address The address the stake is being created for
   * @param _amount uint256 The number of tokens being staked
   * @param _data bytes optional data to include in the Stake event
   */
  function createStake(address _sender, address _stakeFor, uint256 _amount, bytes memory _data)
    internal
    whenNotPaused
    canStake(_sender, _amount)
  {
    stakeHolders[_stakeFor].total = stakeHolders[_stakeFor].total.add(_amount);
    stakeHolders[_sender].stakes.push(Stake(block.number, _amount, 0, _stakeFor));
    emit Staked(_stakeFor, _amount, totalStakedFor(_stakeFor), _data);
  }

  /**
   * @dev Helper function to withdraw stakes back to the original _sender
   * @param _amount uint256 The amount to withdraw. MUST match the stake amount for the
   *  stake at stakeIndex.
   * @param _data bytes optional data to include in the Unstake event
   */
  function withdrawStake(address _sender, uint256 _amount, bytes memory _data)
    internal
    whenNotPaused
  {
    StakeContract storage sc = stakeHolders[_sender];
    uint256 _totalUnstaked = 0;
    while(_amount > 0 || sc.stakeIndex < sc.stakes.length) {
      Stake storage s = sc.stakes[sc.stakeIndex];
      uint256 _remainder = s.amount.sub(s.unstaked);
      uint256 _unstake = Math.min(_amount, _remainder);
      s.unstaked = s.unstaked.add(_unstake);
      _amount = _amount.sub(_unstake);
      _totalUnstaked = _totalUnstaked.add(_unstake);
      stakeHolders[s.stakeFor].total = stakeHolders[s.stakeFor].total.sub(_unstake);
      // Add safe check in case of contract vulnerability
      require(s.amount>=s.unstaked, "Inconsistent staking state.");
      if (s.amount == s.unstaked) stakeHolders[_sender].stakeIndex++;
      emit Unstaked(s.stakeFor, _unstake, totalStakedFor(s.stakeFor), _data);
    }
    if (_totalUnstaked == 0) return;
    // Transfer the staked tokens from this contract back to the sender
    // Notice that we are using transfer instead of transferFrom here.
    require(ERC20tokenContract.transfer(_sender, _totalUnstaked), "Unable to withdraw stake");
  }
}
