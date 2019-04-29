pragma solidity ^0.5.2;

import '../interface/IZtickyStake.sol';
import '../interface/IZtickyCoinZ.sol';
import '../interface/IZtickyBank.sol';

import '../utils/HasZCZ.sol';
import '../roles/FrontendAdmin.sol';

/**
 * @title Frontend
 * @notice The Frontend contract is an interface to all the backend contracts.
 * This structure is useful to simplify the upgradability as it make it possible to separate logic from storage
 * while guaranteeing the correct write permissions to the storage.
 * Current implementation includes a pointer to ZCZ, ZStake and ZBank contract.
 */
contract Frontend is HasZCZ, FrontendAdmin {

  IZtickyStake private _ZStake;
  IZtickyBank private _ZBank;

  /**
   * @dev Make sure the entire logic contract has been correctly configured.
   */
  function isBackendConfigured()
  public
  view
  returns(bool)
  {
    HasZCZ.ZCZ();
    require(address(_ZStake)!=address(0), "ZStake contract not configured.");
    require(address(_ZBank)!=address(0), "ZBank contract not configured.");
    return true;
  }

  /**
   * @dev Change the address of the backend ZStake contract.
   * @param _newAddress The address of the newly deployed contract.
   */
  function changeZStakeContract(address _newAddress)
  public
  onlyFrontendAdmin
  returns(bool)
  {
    require(_newAddress!=address(0), "Address must be specified.");
    require(IZtickyStake(_newAddress).isZStake(), "Address is not a valid backend contract.");
    _ZStake =IZtickyStake(_newAddress);
    return true;
  }

  /**
   * @dev Change the address of the backend ZCZ contract.
   * @param _newAddress The address of the newly deployed contract.
   */
  function changeZCZContract(address _newAddress)
  public
  onlyFrontendAdmin
  returns(bool)
  {
    HasZCZ._setZCZ(_newAddress);
    return true;
  }

  /**
   * @dev Change the address of the backend contract.
   * @param _newAddress The address of the newly deployed contract.
   */
  function changeZBankContract(address payable _newAddress)
  public
  onlyFrontendAdmin
  returns(bool)
  {
    require(_newAddress!=address(0), "Address must be specified.");
    require(IZtickyBank(_newAddress).isZBank(), "Address is not a valid backend contract.");
    _ZBank =IZtickyBank(_newAddress);
    return true;
  }

  /**
   * @dev Return the Backend ZStake contract.
   */
  function ZStake()
  public
  view
  returns(IZtickyStake)
  {
    require(address(_ZStake)!=address(0), "ZStake contract is not configured.");
    return _ZStake;
  }

  /**
   * @dev Return the Backend ZBank contract.
   */
  function ZBank()
  public
  view
  returns(IZtickyBank)
  {
    require(address(_ZBank)!=address(0), "ZStake contract is not configured.");
    return _ZBank;
  }

  /**
   * @dev Return the Backend ZCZ contract.
   */
  function ZCZ()
  public
  view
  returns(IZtickyCoinZ)
  {
    return HasZCZ.ZCZ();
  }
}
