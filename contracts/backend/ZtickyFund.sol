pragma solidity ^0.5.2;

/* import '../interface/IZtickyBank.sol'; */

import "../backend/Backend.sol";
import '../ERC20/ERC20.sol';
import "../utils/SafeMath.sol";
import '../utils/HasZCZ.sol';
import '../utils/DestructibleZCZ.sol';
import "../utils/ReentrancyGuard.sol";



/**
 * @title ZtickyFund
 * @author Samuele Rodi (a.k.a. Sam Fisherman)
 * @notice The ZtickyFund contract is a backend contract that acts as a reserve for the ZtickerZ Governance.
 * Funds in this contract are reserved for operations aimed at the development of the ZtickerZ ecosystem.
 * Destination of funds will be decided by the ZtickerZ Governance, entity which is
 */
contract ZtickyFund is HasZCZ, DestructibleZCZ, Backend {

  constructor(address _zcz) public {
    HasZCZ._setZCZ(_zcz);
  }

  /**
   * @notice Function that confirms that this contract implements a ZtickyBank interface
   * @return true.
   */
  function isZFund()
    public
    pure
    returns(bool)
  {
    return true;
  }

  /**
   * @notice It returns the total balance of the ZBank contract
   * @return An array with the ETH balance and ZCZ balance.
   */
  function totalBalance()
    public
    view
    returns (uint256 _eth, uint256 _zcz)
  {
    _eth = address(this).balance;
    _zcz = this.ZCZ().balanceOf(address(this));
  }



  /**
   * @notice Send ZCZ to an external address
   * @param _account The receipient of the transfer
   * @param _amount The amount of tokens to be sent
   * @return A boolean that indicates if the operation was successful.
   */
  function sendZCZ(address payable _account, uint256 _amount)
    public
    onlyBackendAdmin
    returns (bool)
  {
    require(this.ZCZ().transfer(_account, _amount));
    return true;
  }

  /**
   * @notice Send ether to an external address
   * @param _account The receipient of the transfer
   * @param _amount The amount of ether to be sent
   * @return A boolean that indicates if the operation was successful.
   */
  function sendETH(address payable _account, uint256 _amount)
    public
    onlyBackendAdmin
    returns (bool)
  {
    _account.transfer(_amount);
    return true;
  }


  /**
   * @notice This contract accepts ether payments
   */
  function() external payable {}

}
