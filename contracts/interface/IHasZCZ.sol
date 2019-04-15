pragma solidity ^0.5.2;

import '../interface/IZtickyCoinZ.sol';

interface IHasZCZ {
  function ZCZ() external view returns(IZtickyCoinZ);
}
