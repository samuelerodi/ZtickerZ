pragma solidity ^0.5.2;

import '../interface/IZtickyCoinZ.sol';
import '../interface/IHasZCZ.sol';

/**
 * @title HasZCZ
 * @notice This represent a contract with a direct reference to the ZtickyCoinZ Backend contract.
 * It is used to perform approve or transfer operations for ZCZ.
 */
contract HasZCZ is IHasZCZ {

    IZtickyCoinZ private _ZCZ = IZtickyCoinZ(address(0));

    /**
     * @notice Internally set a contract address and check if the address is a correct ZCZ contract
     */
    function _setZCZ(address _zcz) internal {
      require(_zcz != address(0), "Address must be specified.");
      require(IZtickyCoinZ(_zcz).isZCZ(), "Must be a valid ZCZ contract address");
      _ZCZ = IZtickyCoinZ(_zcz);
    }

    /**
     * @notice Return the Backend ZCZ contract.
     */
    function ZCZ()
    public
    view
    returns(IZtickyCoinZ)
    {
      require(address(_ZCZ)!=address(0), "ZCZ contract is not configured.");
      return _ZCZ;
    }
}
