pragma solidity ^0.5.2;

import './interface/IZtickerZ.sol';
import './interface/IZtickyCoinZ.sol';
import './interface/IZtickyStake.sol';

import './frontend/Frontend.sol';
import './utils/DestructibleZCZ.sol';

/**
 * @title ZtickerZ v0.1
 * @author Samuele Rodi (a.k.a. Sam Fisherman)
 * @notice This ZtickerZ contract is the first release of the ZtickerZ logic contract that implements the functionalities
 * used for inital ZCZ mining through proof-of-stake. This frontend contract is also used as an interface to the staking features
 * of ZtickerZ.
 */
contract ZtickerZ is IZtickerZ, DestructibleZCZ, Frontend {

  bool preminingFinished;
  uint256 public currentPayoutIdx;
  uint256 public nextPayoutTimestamp;
  uint256 public payoutsInterval = 2629800;
  uint256 public preminedZCZSupply = 21000000 * 1 ether;
  uint256[] payoutInterestRates = [6,6,6,6,6,5,5,5,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1];

  /**
   * @notice This checks that the caller is strictly an externally owned account.
   * This is necessary for interacting with Backend contracts because Backends use the tx.origin
   * to identify the legit issuer of transactions. This is done especially for security reasons,
   * i.e. to avoid relying on a single point of failure, represented by the BackendAdmin,
   * for sensitive transactions, which modify the supply of ZCZ (minting and burning).
   */
  modifier onlyExternal() {
    require(tx.origin == msg.sender, "Only externally owned account can interact with the contract");
    _;
  }

  /**
   * @notice Returns the expected amount of redeemable dividends for the stakeholder.
   * @param _stakeFor The address of the stakeholder.
   * @return An array with the ETH dividend and ZCZ dividend.
   */
  function expectedDividends(address _stakeFor) public
    view
    returns (uint256, uint256)
  {
    uint256 _shares = Frontend.ZStake().sharesOf(_stakeFor);
    return Frontend.ZBank().outstandingDividendsFor(_shares);
  }

  /**
   * @notice Returns the expected amount of redeemable dividends for the stakeholder.
   * @param _stakedBy The address owner of the stake.
   * @param _stakeFor The address for which the stake is being held.
   * @return An array with the ETH dividend and ZCZ dividend.
   */
  function expectedDividendsFor(address _stakedBy, address _stakeFor) public
    view
    returns (uint256, uint256)
  {
    uint256 _shares = Frontend.ZStake().sharesOfFor(_stakedBy, _stakeFor);
    return Frontend.ZBank().outstandingDividendsFor(_shares);
  }

    /**
     * @notice Function to mint tokens, restricted to frontend admins only.
     * This function can be triggered once only and it is used for the initial premined supply of ZCZ tokens specified inside this contract.
     * @param _to The address that will receive the minted tokens.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to) public
      onlyExternal
      onlyFrontendAdmin
      whenNotPaused
      returns (bool)
    {
      require(!preminingFinished, "Premining has already occured");
      preminingFinished = true;
      nextPayoutTimestamp = block.timestamp + payoutsInterval;
      Frontend.ZCZ().mint(_to, preminedZCZSupply);
      return true;
    }

    /**
     * @notice Function to pay token dividends issued through proof-of-stake.
     * This function can be invoked by anyone but triggers change only when the next payout time has reached.
     * It modifies the ZCZ premined supply through the proof-of-stake using a predetermined interest rate pattern.
     * @return A boolean that indicates if the operation was successful.
     */
    function payDividends() public
      onlyExternal
      whenNotPaused
      returns (bool)
    {
      require(preminingFinished, "Should have already minted coins");
      require(currentPayoutIdx < payoutInterestRates.length, "Planned payouts have ended");
      require(nextPayoutTimestamp!=0, "It needs a timestamp for payouts");
      require(block.timestamp > nextPayoutTimestamp, "Dividends payout time has not come yet");
      uint256 _currentInterest = 100 + payoutInterestRates[currentPayoutIdx];
      uint256 _amount = (preminedZCZSupply * _currentInterest) / 100;
      currentPayoutIdx++;
      preminedZCZSupply += _amount;
      nextPayoutTimestamp += payoutsInterval;
      Frontend.ZCZ().mint(address(Frontend.ZBank()), _amount);
      return true;
    }


    /**
    * @notice This function allows the user to stake his own tokens for a different account.
    * The stakeholder remains the owner of the ZCZ tokens and the only entitled to withdraw the stake at any time,
    * but the beneficiary of the staking will receive the benefit of the staking (dividends).
    * It performs the pre approval, transfer and staking in a single transaction.
    * @param _stakeFor The address beneficiary of the stake.
    * @param _value The amount of ZCZ to be staked.
    */
    function stakeFor(address _stakeFor, uint256 _value) public
    onlyExternal
    whenNotPaused
    returns (bool)
    {
      IZtickyStake _zs = Frontend.ZStake();
      require(Frontend.ZCZ().authorizedApprove(address(_zs), _value));
      require(_zs.authorizedStakeFor(_stakeFor, _value));
      return true;
    }

    /**
    * @notice This function allows to unstake an arbitrary amount of tokens for another account
    * which has a "stakeFor" ongoing and gives the benefits of all the staked tokens that have matured some shares
    * to the beneficiary of the stake, while it returns the staked tokens to the legit owner.
    * @param _stakeFor The address beneficiary of the stake.
    * @param _value The amount of tokens to be unstaked.
    */
    function unstakeFor(address payable _stakeFor, uint256 _value) public
    onlyExternal
    whenNotPaused
    returns (bool)
    {
      uint256 _unvestedShares = Frontend.ZStake().authorizedUnstakeFor(_stakeFor, _value);
      if (_unvestedShares>0) Frontend.ZBank().payout(_stakeFor, _unvestedShares, true, true);
      return true;
    }

    /**
     * @notice This function allows the user to stake tokens in the staking contract on behalf of himself without
     * needing to pre-approve a token transfer to the staking contract.
     * This is to reduce user interactions and increase user experience.
     * @param _value The amount of ZCZ to be staked.
     */
    function stake(uint256 _value) public
      returns (bool)
    {
      return stakeFor(msg.sender, _value);
    }

    /**
     * @notice This function allows to unstake an arbitrary amount of tokens and receive the
     * benefits of all the staked tokens that have matured some shares.
     * @param _value The amount of tokens to be unstaked.
     */
    function unstake(uint256 _value) public
      returns (bool)
    {
      return unstakeFor(msg.sender, _value);
    }

    /**
     * @notice This function is useful for any stakeholder to claim and receive all the outstanding dividends
     * accrued for a different account and restake all of them without performing two different operations.
     * @param _stakeFor The address beneficiary of the stake.
     */
    function claimDividendsAndRestakeFor(address payable _stakeFor) public
      returns (bool)
    {
      uint256 _maturedTokens = Frontend.ZStake().maturedTokensOfFor(msg.sender, _stakeFor);
      unstakeFor(_stakeFor, _maturedTokens);
      stakeFor(_stakeFor, _maturedTokens);
      return true;
    }

    /**
     * @notice This function is useful for any stakeholder to claim and receive all the outstanding dividends
     * and restake all of its tokens without having to perform two different operations.
     */
    function claimDividendsAndRestake() public
    returns (bool)
    {
      return claimDividendsAndRestakeFor(msg.sender);
    }

    /**
     * @notice This contract accepts ether payments
     */
    function() external payable {}
}
