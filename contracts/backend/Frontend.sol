pragma solidity ^0.5.2;

import '../utils/Ownable.sol';

import '../interface/ZtickyStake.sol';
import '../interface/ZtickyCoinZ.sol';

/**
 * @title Frontend
 * @dev The Frontend contract is an interface to all the backend contracts.
 * This structure is useful to simplify the upgradability as it make it possible to separate logic from storage
 * while guaranteeing the correct write permissions to the storage.
 * Current implementation includes a pointer to the ZtickyCoinZ contract.
 */
contract Frontend is Ownable{
  address private _ZCZAddress = address(0);
  ZtickyCoinZ private _ZCZ = ZtickyCoinZ(_ZCZAddress);

  address private _ZStakeAddress = address(0);
  ZtickyStake private _ZStake = ZtickyStake(_ZStakeAddress);

  /**
   * @dev Make sure the entire logic contract has been correctly configured.
   */
  function isBackendConfigured()
  public
  view
  returns(bool)
  {
    require(_ZCZAddress!=address(0), "ZtickyCoinZ contract not configured.");
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
    require(ZtickyStake(_newAddress).isBackend(), "Address is not a valid backend contract.");
    _ZStakeAddress = _newAddress;
    _ZStake =ZtickyStake(_ZStakeAddress);
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
    require(ZtickyCoinZ(_newAddress).isBackend(), "Address is not a valid backend contract.");
    _ZCZAddress = _newAddress;
    _ZCZ =ZtickyCoinZ(_ZCZAddress);
    return true;
  }

  /**
   * @dev Return the Backend ZCZ contract.
   */
  function ZCZ()
  public
  view
  returns(ZtickyCoinZ)
  {
    return _ZCZ;
  }

  /**
   * @dev Return the Backend ZStake contract.
   */
  function ZStake()
  public
  view
  returns(ZtickyStake)
  {
    return _ZStake;
  }
}
