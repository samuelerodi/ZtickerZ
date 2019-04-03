pragma solidity ^0.5.2;

import '../utils/Ownable.sol';

import '../interface/IZtickyStake.sol';
import '../interface/IZtickyCoinZ.sol';

/**
 * @title Frontend
 * @dev The Frontend contract is an interface to all the backend contracts.
 * This structure is useful to simplify the upgradability as it make it possible to separate logic from storage
 * while guaranteeing the correct write permissions to the storage.
 * Current implementation includes a pointer to the ZCZ and ZStake contract.
 */
contract Frontend is Ownable{

  IZtickyCoinZ private _ZCZ = IZtickyCoinZ(address(0));
  IZtickyStake private _ZStake = IZtickyStake(address(0));

  /**
   * @dev Make sure the entire logic contract has been correctly configured.
   */
  function isBackendConfigured()
  public
  view
  returns(bool)
  {
    require(address(_ZCZ)!=address(0), "_ZCZ contract not configured.");
    require(address(_ZStake)!=address(0), "ZStake contract not configured.");
    return true;
  }

  /**
   * @dev Change the address of the backend contract.
   * @param _newAddress The address of the newly deployed contract.
   */
  function changeZStakeContract(address _newAddress)
  public
  onlyOwner
  returns(bool)
  {
    require(_newAddress!=address(0), "Address must be specified.");
    require(IZtickyStake(_newAddress).isZStake(), "Address is not a valid backend contract.");
    _ZStake =IZtickyStake(_newAddress);
    return true;
  }

  /**
   * @dev Change the address of the backend contract.
   * @param _newAddress The address of the newly deployed contract.
   */
  function changeZCZContract(address _newAddress)
  public
  onlyOwner
  returns(bool)
  {
    require(_newAddress!=address(0), "Address must be specified.");
    require(IZtickyCoinZ(_newAddress).isZCZ(), "Address is not a valid backend contract.");
    _ZCZ =IZtickyCoinZ(_newAddress);
    return true;
  }

  /**
   * @dev Return the Backend ZCZ contract.
   */
  function ZCZ()
  public
  view
  returns(IZtickyCoinZ)
  {
    require(address(_ZCZ)!=address(0), "ZCZ contract is not configured.");
    return _ZCZ;
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
}
