pragma solidity ^0.4.24;

import './utils/Backend.sol';
/* import './utils/ArrayUtils.sol'; */
import 'openzeppelin-solidity/contracts/ownership/HasNoEther.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';

/**
 * @title StickersStorage
 * @dev The StickersStorage contract is a backend ERC721 storage contract which collects all the user stickers
 * implementing a generate and burn function which is triggerable only by frontend.
 * The logic is implemented in its frontend contract which has been separated from the backend sticker ERC721 contracts
 * for upgradability reasons. In this way the storage contract remains
 * as flexible as possible for further future updates.
 */
contract StickersStorage is  HasNoEther, Backend(address(0)), ERC721Token("ZtickerZ", "ZTK")  {

  /**
  * @dev Gets all sIds of the specified address
  * @param _owner address for the sticker's owner
  * @return uint256[] representing all sticker ids owned by the passed address
  */
  function getStickersOf(address _owner)
  external view returns (uint256[]) {
    require(_owner != address(0));
    return ownedTokens[_owner];
  }

  /**
  * @dev Generate new sticker by calling _mint function
  * @param _owner address for the sticker's owner
  * @param _stickerId sticker unique id
  * @return uint256 representing length of owned stickers by the passed address
  */
  function generateSticker(address _owner, uint256 _stickerId) public
  onlyFrontend
  returns (uint256) {
    //It could be used tx.origin instead of _owner for a fully trustless system
    ERC721Token._mint(_owner, _stickerId);
    return ownedTokens[_owner].length;
  }


  /**
  * @dev Burn sticker by calling _burn function. Not currently used but added for flexibility.
  * @param _owner address for the sticker's owner
  * @param _stickerId sticker unique id
  * @return uint256 representing length of owned stickers by the passed address
  */
  function burnSticker(address _owner, uint256 _stickerId) public
  onlyFrontend
  returns (uint256) {
    //It could be used tx.origin instead of _owner for a fully trustless system
    ERC721Token._burn(_owner, _stickerId);
    return ownedTokens[_owner].length;
  }

  /**
  * @dev Extend approve function and publish onto market to be sold
  * @param _stickerId sticker's unique id
  * @param price price to be published to market
  * @return uint256 representing all deed IDs owned by the passed address
  */
  function approveAndSell(uint256 _stickerId, uint256 price) public
  returns (uint256) {
    ERC721BasicToken.approve(frontend, _stickerId);
    /* frontend.publishToMarket(_tokenId, price); */
    return price;
  }








///OLD IMPLEMENTATION
  /* using ArrayUtils for uint[]; */

  /* mapping (address => mapping (uint => uint[])) public albums;
  mapping (uint => uint) public globalStickersCounter;

  constructor() public {
  } */

  /**
  * @dev Get full album by user
  */
  /* function getUserAlbum(address _user) public view returns (mapping (uint => string[])) {
    return albums[_user];
  } */
  /**
  * @dev Get full album by user
  */
  /* function getUserStickers(address _user, uint _from, uint _to) public view returns (uint[]) {
    uint counter = 0;
    for (uint l = _from; l < _to; l++) {
      counter += albums[_user][l].length;
    }
    uint[] memory stickers = new uint[](counter);
    for (uint i = _from; i < _to; i++) {
      for (uint s = 0; s < albums[_user][i].length; s++) {
        stickers[s]=albums[_user][i][s];
      }
    }
    return stickers;
  } */
  /**
  * @dev Get full album by user
  */
  /* function getUserStickersByStn(address _user, uint _stn) public view returns (uint[]) {
    return albums[_user][_stn];
  } */
  /**
  * @dev Get full album by user
  * Returns the count of stickers with same stn of current user
  */
  /* function addSticker(address _user, uint _stn, uint _sId) public
  onlyFrontend
  returns (uint) {
    return albums[_user][_stn].push(_sId);
  } */
  /**
  * @dev Get full album by user
  */
  /* function removeSticker(address _user, uint _stn, uint _sId) public
  onlyFrontend
  returns (uint) {
    var (found, idx) = albums[_user][_stn].indexOf(_sId, true);
    assert(found);
    assert((albums[_user][_stn].length -1) == albums[_user][_stn].remove(idx));
    return albums[_user][_stn].length;
  } */
}
