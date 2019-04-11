pragma solidity ^0.5.2;

import './frontend/Frontend.sol';

import './interface/IZtickerZ.sol';
import './interface/IZtickyCoinZ.sol';
import './interface/IZtickyStake.sol';

import './utils/Destructible.sol';
import "./utils/Pausable.sol";

/**
 * @title ZtickerZMock
 * @dev The ZtickerZMock contract is a basic logic contract implementing basic functionalities
 * used for ZCZ distribution prior to full version release.
 */
contract ZtickerZ is IZtickerZ, Frontend, Destructible, Pausable {


  /**
   * @dev Modifier that checks that the caller is strictly an externally owned account.
   * This is necessary for interacting with the Backend contracts and it is also added
   * for security reasons.
   */
  modifier onlyExternal() {
    require(tx.origin == msg.sender, "Only externally owned account can interact with the contract");
    _;
  }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount)
      onlyExternal
      onlyOwner
      whenNotPaused
      public
      returns (bool)
    {
      Frontend.ZCZ().mint(_to, _amount);
      return true;
    }

    /**
     * @dev This function allows the frontend contract to directly withdraw from user balance in order
     * to reduce user interactions when invoked from logic contract.
     * @param value The amount of approval.
     */
    function stake(uint256 value) public
      onlyExternal
      whenNotPaused
      returns (bool)
    {
      IZtickyStake _zs = Frontend.ZStake();
      require(Frontend.ZCZ().authorizedApprove(address(_zs), value));
      require(_zs.authorizedStake(value));
      return true;
    }

    /**
     * @dev This function allows the frontend contract to directly withdraw from user balance in order
     * to reduce user interactions when invoked from logic contract.
     * @param value The amount of approval.
     */
    function stakeFor(address _stakeFor, uint256 value) public
      onlyExternal
      whenNotPaused
      returns (bool)
    {
      IZtickyStake _zs = Frontend.ZStake();
      require(Frontend.ZCZ().authorizedApprove(address(_zs), value));
      require(_zs.authorizedStakeFor(_stakeFor, value));
      return true;
    }

    /**
     * @dev This function allows the frontend contract to directly withdraw from user balance in order
     * to reduce user interactions when invoked from logic contract.
     * @param value The amount of approval.
     */
    function unstake(uint256 value) public
      onlyExternal
      whenNotPaused
      returns (bool)
    {
      uint256 _unvestedShares = Frontend.ZStake().authorizedUnstake(value);
      if (_unvestedShares>0) Frontend.ZBank().payout(msg.sender, _unvestedShares);
      return true;
    }

    /**
     * @dev This function allows the frontend contract to directly withdraw from user balance in order
     * to reduce user interactions when invoked from logic contract.
     * @param _stakeFor The address for approval.
     * @param value The amount of approval.
     */
    function unstakeFor(address payable _stakeFor, uint256 value) public
      onlyExternal
      whenNotPaused
      returns (bool)
    {
      uint256 _unvestedShares = Frontend.ZStake().authorizedUnstakeFor(_stakeFor, value);
      if (_unvestedShares>0) Frontend.ZBank().payout(_stakeFor, _unvestedShares);
      return true;
    }

    /**
     * @dev This function allows the frontend contract to directly withdraw from user balance in order
     * to reduce user interactions when invoked from logic contract.
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
     * @dev This function allows the frontend contract to directly withdraw from user balance in order
     * to reduce user interactions when invoked from logic contract.
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
