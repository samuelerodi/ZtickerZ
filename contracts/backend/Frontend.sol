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
  address private _ZCZAddress = address(0);
  IZtickyCoinZ private _ZCZ = IZtickyCoinZ(_ZCZAddress);

  address private _ZStakeAddress = address(0);
  IZtickyStake private _ZStake = IZtickyStake(_ZStakeAddress);

  /**
   * @dev Make sure the entire logic contract has been correctly configured.
   */
  function isBackendConfigured()
  public
  view
  returns(bool)
  {
    require(_ZCZAddress!=address(0), "_ZCZ contract not configured.");
    require(_ZStakeAddress!=address(0), "ZStake contract not configured.");
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
    require(IZtickyStake(_newAddress).isBackend(), "Address is not a valid backend contract.");
    _ZStakeAddress = _newAddress;
    _ZStake =IZtickyStake(_ZStakeAddress);
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
    require(IZtickyCoinZ(_newAddress).isBackend(), "Address is not a valid backend contract.");
    _ZCZAddress = _newAddress;
    _ZCZ =IZtickyCoinZ(_ZCZAddress);
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
    return _ZStake;
  }
}
