pragma solidity ^0.5.2;

import './interface/IZtickerZ.sol';
import './interface/IZtickyCoinZ.sol';
import './interface/IZtickyStake.sol';

import './frontend/Frontend.sol';
import './utils/DestructibleZCZ.sol';

/**
 * @title ZtickerZ v0.1
 * @author Samuele Rodi (a.k.a. Sam Fisherman)
 * @notice This ZtickerZ contract is the first release of the ZtickerZ logic contract that implements the basic functionalities
 * used for ZCZ distribution and staking features. This frontend contract will be dismissed as soon as the full release
 * of ZtickerZ will be available.
 */
contract ZtickerZ is IZtickerZ, DestructibleZCZ, Frontend {

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
     * @notice Function to mint tokens, restricted to frontend admins only.
     * This function currently represents a single point of failure as it rely on a single account
     * capable of modifying the ZCZ supply (minting).
     * @dev This function will be removed in a future release of the ZtickerZ logic contract.
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount)
      onlyExternal
      onlyFrontendAdmin
      whenNotPaused
      public
      returns (bool)
    {
      Frontend.ZCZ().mint(_to, _amount);
      return true;
    }

    /**
     * @notice This function allows the user to stake tokens in the staking contract on behalf of himself without
     * needing to pre-approve a token transfer to the staking contract.
     * This is to reduce user interactions and increase user experience.
     * @param _value The amount of ZCZ to be staked.
     */
    function stake(uint256 _value) public
      onlyExternal
      whenNotPaused
      returns (bool)
    {
      IZtickyStake _zs = Frontend.ZStake();
      require(Frontend.ZCZ().authorizedApprove(address(_zs), _value));
      require(_zs.authorizedStake(_value));
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
     * @notice This function allows to unstake an arbitrary amount of tokens and receive the
     * benefits of all the staked tokens that have matured some shares.
     * @param _value The amount of tokens to be unstaked.
     */
    function unstake(uint256 _value) public
      onlyExternal
      whenNotPaused
      returns (bool)
    {
      uint256 _unvestedShares = Frontend.ZStake().authorizedUnstake(_value);
      if (_unvestedShares>0) Frontend.ZBank().payout(msg.sender, _unvestedShares);
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
      if (_unvestedShares>0) Frontend.ZBank().payout(_stakeFor, _unvestedShares);
      return true;
    }

    /**
     * @notice This function is useful for any stakeholder to claim and receive all the outstanding dividends
     * and restake all of its tokens without having to perform two different operations.
     */
    function claimDividendsAndRestake() public
      returns (bool)
    {
      uint256 _maturedTokens = Frontend.ZStake().maturedTokensOf(msg.sender);
      unstake(_maturedTokens);
      stake(_maturedTokens);
      return true;
    }

    /**
     * @notice This function is useful for any stakeholder to claim and receive all the outstanding dividends
     * accrued for a different account and restake all of them without performing two different operations.
     * @param _stakeFor The address beneficiary of the stake.
     */
    function claimDividendsAndRestakeFor(address payable _stakeFor) public
      returns (bool)
    {
      uint256 _maturedTokens = Frontend.ZStake().maturedTokensByFor(msg.sender, _stakeFor);
      unstakeFor(_stakeFor, _maturedTokens);
      stakeFor(_stakeFor, _maturedTokens);
      return true;
    }
}
