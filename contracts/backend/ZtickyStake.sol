pragma solidity ^0.5.2;

import '../backend/Backend.sol';
import '../utils/HasNoEther.sol';
import '../ERC900/ERC900.sol';
import '../ERC20/ERC20.sol';

/**
 * @title ZStake
 * @dev The ZStake contract is a backend ERC900 contract used as storage for staking features.
 * It supports history and implements an interface callable exclusively from the logic contract
 */
contract ZtickyStake is ERC900, HasNoEther, Backend {

  constructor(address _zcz) ERC900(ERC20(_zcz)) public {}


}
