pragma solidity ^0.5.7;

import './backend/Backend.sol';
import './utils/HasNoEther.sol';
import './ERC20/ERC20Pausable.sol';
import './ERC20/ERC20Detailed.sol';

/**
 * @title ZtickyCoinZ
 * @dev The ZtickyCoinZ contract is a backend ERC20 token contract which collects the ZtickyCoinZ associated
 * to the ZtickerZ contract. It is mostly a standard ERC20 token plus functions accessible
 * from the frontend contract. The separation has been conceived for upgradability reasons
 * while keeping the contracts as flexible as possible.
 */
contract ZtickyCoinZ is ERC20Pausable, ERC20Detailed("ZtickyCoinZ","ZCZ", 18), HasNoEther, Backend {

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount)
    onlyFrontend
    whenNotPaused
    public
    returns (bool)
  {
    ERC20Pausable._mint(to, _amount);
    return true;
  }


  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public
  onlyFrontend
  whenNotPaused
  returns(bool)
  {
    //tx.origin because only the legitimate caller is allowed to burn coin
    ERC20Pausable._burn(tx.origin, _value);
    return true;
  }

  // /**
  //  * @dev This function allows to send directly tokens to market contract in order to trade for specific sticker.
  //  * @param _stickerId The unique id of the sticker to be bought.
  //  */
  // function buyAndTransfer(uint256 _stickerId)
  // public
  // whenNotPaused
  // returns(bool)
  // {
  //   (, uint256 price) = MarketInterface(frontend).getItemOnSale(_stickerId);
  //   require(price <= balances[msg.sender], 'Price should be lower than balance');
  //   PausableToken.approve(frontend, price);
  //   MarketInterface(frontend).sellItem(_stickerId, msg.sender);
  //   return true;
  // }

  /**
   * @dev This function allows the frontend contract to directly withdraw from user balance in order
   * to reduce user interactions when invoked from logic contract.
   * @param spender The address of the approved spender.
   * @param value The amount of approval.
   */
  function frontendApprove(address spender, uint256 value) public
  onlyFrontend
  whenNotPaused
  returns (bool) {
    //tx.origin because only the legitimate caller is allowed to grant approval
    ERC20Pausable._approve(tx.origin, spender, value);
    return true;
  }

}
