pragma solidity ^0.5.2;

import '../interface/IZtickyCoinZ.sol';

/**
 * @title IHasZCZ
 * @notice Owns a reference to the ZCZ contract for operation like query balances or transfering tokens
 */
interface IHasZCZ {
  function ZCZ() external view returns(IZtickyCoinZ);
}
