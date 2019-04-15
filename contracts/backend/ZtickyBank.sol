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
 * @dev The ZtickyBank contract is a backend contract that keeps all the funds redeemable
 * by ZtickerZ stakeholders. It is a backend contract since it has the only purpose of storing
 * value while the logic is implemented in the Frontend contract.
 */
contract ZtickyBank is IZtickyBank, HasZCZ, DestructibleZCZ, ReentrancyGuard, Backend {

  using SafeMath for uint256;

  uint256 public totalShares = 1 ether;

  constructor(address _zcz) public {
    HasZCZ._setZCZ(_zcz);
  }

  function isZBank()
  public
  pure
  returns(bool)
  {
    return true;
  }

  function totalBalance()
  public
  view
  returns (uint256 _eth, uint256 _zcz)
  {
    _eth = address(this).balance;
    _zcz = this.ZCZ().balanceOf(address(this));
  }

  function outstandingDividendsPerShare()
  public
  view
  returns (uint256, uint256)
  {
    (uint256 _totalETH, uint256 _totalZCZ) = totalBalance();
    return (_totalETH.div(totalShares), _totalZCZ.div(totalShares));
  }

  function outstandingDividendsFor(uint256 _shares)
  public
  view
  returns (uint256, uint256)
  {
    require(_shares<=totalShares, "Shares must be lower than total");
    (uint256 _totalETH, uint256 _totalZCZ) = totalBalance();
    return (_totalETH.mul(_shares).div(totalShares), _totalZCZ.mul(_shares).div(totalShares));
  }

  function payout(address payable _account, uint256 _shares)
  public
  onlyFrontend
  nonReentrant
  returns (bool)
  {
    (uint256 _eth, uint256 _zcz) = outstandingDividendsFor(_shares);
    emit Withdraw(_account, _eth, _zcz);
    if (_zcz>0) require(this.ZCZ().transfer(_account, _zcz));
    if (_eth>0) _account.transfer(_eth);
  }

  function() external payable {}
}
