pragma solidity ^0.5.2;

import './interface/IZtickerZ.sol';

import './utils/Destructible.sol';
import './backend/Frontend.sol';
import "./utils/Pausable.sol";

/**
 * @title ZtickerZMock
 * @dev The ZtickerZMock contract is a basic logic contract implementing basic functionalities
 * used for ZCZ distribution prior to full version release.
 */
contract ZtickerZ is IZtickerZ, Frontend, Destructible, Pausable {


    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount)
      onlyOwner
      whenNotPaused
      public
      returns (bool)
    {
      Frontend.ZCZ().mint(_to, _amount);
      return true;
    }

    /**
     * @dev This function allows the frontend contract to directly withdraw from user balance in order
     * to reduce user interactions when invoked from logic contract.
     * @param value The amount of approval.
     */
    function stake(uint256 value) public
      whenNotPaused
      returns (bool)
    {
      Frontend.ZCZ().authorizedApprove(address(this), value);
      Frontend.ZStake().authorizedStake(value, "ZtickerZv01");
      return true;
    }


    /**
     * @dev This function allows the frontend contract to directly withdraw from user balance in order
     * to reduce user interactions when invoked from logic contract.
     * @param value The amount of approval.
     */
    function unstake(uint256 value) public
      whenNotPaused
      returns (bool)
    {
      Frontend.ZCZ().authorizedApprove(address(this), value);
      Frontend.ZStake().authorizedUnstake(value, "ZtickerZv01");
      return true;
    }
}
