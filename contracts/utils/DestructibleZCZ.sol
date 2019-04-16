pragma solidity ^0.5.2;

import '../interface/IZtickyCoinZ.sol';
import "../interface/IHasZCZ.sol";
import "../utils/Destructible.sol";
import "../utils/Pausable.sol";

/**
 * @title DestructibleZCZ
 * @dev Base contract which holds ether as well as ZCZ and can be destroyed by owner.
 * All funds in contract will be sent to the owner specified address.
 */
contract DestructibleZCZ is IHasZCZ, Pausable, Destructible {

  /**
   * @dev Transfers the current ZCZ balance to the recipient and allow proceeding to destroying the contract.
   */
  modifier emergencyTransfer(address _recipient) {
    uint256 _balance = this.ZCZ().balanceOf(address(this));
    if (_balance!=0) require(this.ZCZ().transfer(_recipient, _balance), "Transfer of contract balance is required!");
    _;
  }

  /**
   * @dev Transfers the current ZCZ and ETH balance to the owner and terminates the contract.
   * Invokable by any contract admin
   */
  function destroy()
    whenPaused
    onlyAdmin
    emergencyTransfer(Ownable.owner())
    public
  {
    selfdestruct(Ownable.owner());
  }

  /**
   * @dev Transfers the current ZCZ and ETH balance to the specified recipient and terminates the contract.
   * Invokable by the owner of the contract only
   */
  function destroyAndSend(address payable _recipient)
    whenPaused
    onlyOwner
    emergencyTransfer(_recipient)
    public
  {
    return Destructible.destroyAndSend(_recipient);
  }
}
