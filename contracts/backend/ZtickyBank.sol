pragma solidity ^0.5.2;

import '../interface/IZtickyBank.sol';

import "../backend/Backend.sol";
import '../ERC20/ERC20.sol';
import "../utils/SafeMath.sol";
import '../utils/HasZCZ.sol';
import '../utils/DestructibleZCZ.sol';
import "../utils/ReentrancyGuard.sol";



/**
 * @title ZtickyBank
 * @author Samuele Rodi (a.k.a. Sam Fisherman)
 * @notice The ZtickyBank contract is a backend contract whose goal is to retain all the funds redeemable
 * by ZtickerZ stakeholders in the forms of dividends. It is a backend contract since it has the only
 * purpose of storing value, while the logic is implemented in the Frontend contract.
 */
contract ZtickyBank is IZtickyBank, HasZCZ, DestructibleZCZ, ReentrancyGuard, Backend {

  using SafeMath for uint256;

  /**
   * @dev The number of outstanding shares as per standard
   */
  uint256 public totalShares = 1 ether;

  constructor(address _zcz) public {
    HasZCZ._setZCZ(_zcz);
  }

  /**
   * @notice Function that confirms that this contract implements a ZtickyBank interface
   * @return true.
   */
  function isZBank()
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
   * @notice Computes the expected dividend in both ETH and ZCZ for each single share
   * @return An array with the ETH dividend and ZCZ dividend.
   */
  function outstandingDividendsPerShare()
    public
    view
    returns (uint256, uint256)
  {
    (uint256 _totalETH, uint256 _totalZCZ) = totalBalance();
    return (_totalETH.div(totalShares), _totalZCZ.div(totalShares));
  }

  /**
   * @notice Computes the expected dividend in both ETH and ZCZ for a specified amount of shares
   * @param _shares The amount of owned shares by the users for which dividends are being requested
   * @return An array with the ETH dividend and ZCZ dividend.
   */
  function outstandingDividendsFor(uint256 _shares)
    public
    view
    returns (uint256, uint256)
  {
    require(_shares<=totalShares, "Shares must be lower than total");
    (uint256 _totalETH, uint256 _totalZCZ) = totalBalance();
    return (_totalETH.mul(_shares).div(totalShares), _totalZCZ.mul(_shares).div(totalShares));
  }

  /**
   * @notice Computes the expected dividend in both ETH and ZCZ for each single share
   * @param _account The receipient of the redeemed dividends
   * @param _shares The amount of owned shares by the account for which dividends are being sent
   * @param _payETH boolean to specify if dividends in ETH are being sent
   * @param _payZCZ boolean to specify if dividends in ZCZ are being sent
   * @return A boolean that indicates if the operation was successful.
   */
  function payout(address payable _account, uint256 _shares, bool _payETH, bool _payZCZ)
    public
    onlyFrontend
    nonReentrant
    returns (bool)
  {
    (uint256 _eth, uint256 _zcz) = outstandingDividendsFor(_shares);
    emit Withdraw(_account, _eth, _zcz);
    if (_payZCZ && _zcz>0) require(this.ZCZ().transfer(_account, _zcz));
    if (_payETH && _eth>0) _account.transfer(_eth);
    return true;
  }

  /**
   * @notice This contract accepts ether payments
   */
  function() external payable {}

}
