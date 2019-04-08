pragma solidity ^0.5.2;

import '../interface/IZtickyCoinZ.sol';
import "../utils/Destructible.sol";
import "../utils/Pausable.sol";
import "../backend/Backend.sol";

/**
 * @title DestructibleZCZ
 * @dev Base contract which holds ether as well as ZCZ and can be destroyed by owner.
 * All funds in contract will be sent to the owner specified address.
 */
contract DestructibleZCZ is Destructible, Backend, Pausable {
  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
   // Token contract used
  IZtickyCoinZ private zcz;

  constructor(IZtickyCoinZ _zcz) public {
    require(address(_zcz) != address(0));
    require(_zcz.isZCZ(), "Must be a valid ZCZ contract address");
    zcz = _zcz;
  }

  modifier emergencyTransfer(address _recipient) {
   require(zcz.transfer(_recipient, zcz.balanceOf(address(this))), "Transfer of contract balance is required!");
   _;
  }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy()
  whenPaused
  onlyBackendAdmin
  emergencyTransfer(Ownable.owner())
  public
  {
    selfdestruct(Ownable.owner());
  }

  function destroyAndSend(address payable _recipient)
  whenPaused
  onlyOwner
  emergencyTransfer(_recipient)
  public
  {
    return Destructible.destroyAndSend(_recipient);
  }
}
