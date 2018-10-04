pragma solidity ^0.4.24;

import './utils/DecentralizedMarket.sol';
import './utils/SeedGenerator.sol';
import './utils/TipsManager.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/lifecycle/Destructible.sol';

// ZtickerZ AVAILABLE FUNCTIONS:
// + GLOBAL
// - view
// function computeCoinReward(uint16 _albumId, uint16 _stn) public view returns(uint256 out)
// function isAlbumComplete(address _owner, uint16 _albumId) public view isFrontendConfigured albumExist(_albumId) returns(bool)
// function getStickerDetails(uint256 _stickerId) public view isFrontendConfigured returns(uint16 _albumId, uint16 _stn, uint256 _sId, address _owner, bool _onSale, uint256 _onSalePrice)
// function getAlbumStats(uint16 _albumId) public view albumExist(_albumId) returns ( uint16 _nStickers, uint256 _nStickersPerPack, uint256 _packPrice, uint256 _ethReceived, uint256 _mintedCoins, uint256 _burntCoins, uint256 _nStickersInCirculation, uint256[] _stnDistribution, uint256[] _nextStnGenReward, address[] _rewardedUsers)
// function computeAlbumReward(uint16 _albumId, uint256 _coinToBurn) public view albumExist(_albumId) returns(uint256 _eth, uint256 _tips)
// - write
// function createAlbum(uint16 _nS, uint16 _nSxPack, uint256 _packPrice) public onlyOwner returns(uint16)
// function unwrapStickerPack(uint16 _albumId) public payable whenNotPaused isFrontendConfigured albumExist(_albumId) returns(uint256[] out)
// function redeemReward(uint16 _albumId, uint256 _coinToBurn) public whenNotPaused isFrontendConfigured albumExist(_albumId) returns(bool)
// + MARKET
// - view
// function getItemOnSale(uint256 _stickerId) public view isOnSale(_stickerId) returns(address, uint256)
// function getOrderBook()public view returns(uint256[] _stickers, uint256[] _prices, address[] _sellers)
// - write
// function cancelSellOrder(uint256 _stickerId) public whenNotPaused returns(bool)
// + ADMIN
// function pause() onlyOwner whenNotPaused public
// function unpause() onlyOwner whenPaused public
// function adminCancelSellOrder(uint256 _stickerId, address _seller) public onlyOwner returns(bool)
// function adminClearSellOrder(uint256 _stickerId) public onlyOwner returns(bool)
// function changeTipsAddress(address _newTipAddress) public onlyOwner returns(address)


/**
 * @title ZtickerZ
 * @dev The ZtickerZ contract is a DecentralizedMarket Frontend contract which implements all the logic for
 * the album management, stickers generation and user reward upon album completion.
 * For sake of simplicity, the sticker generation is handled using the SeedGenerator contract which is currently vulnerable
 * to miner manipulation. This implementation is tollerated as long as the sticker pack value doesn't exceed the mining reward.
 * However, this functionality will be upgraded in the future using a commit-reveal approach for a complete trustless random seed generation.
 */
contract ZtickerZ is Destructible, DecentralizedMarket, SeedGenerator, TipsManager {
  event Log(string _s, uint256 _n);
  event Zticker(address _owner, uint16 indexed _albumId, uint16 indexed _stn, uint256 _stickerId);
  event AlbumComplete(address indexed _owner, uint256 _burntCoin, uint256 _rewardedEth);


  using SafeMath for uint256;
  uint16 public albumCount;
  uint256 public totalEthReceived;
  uint256 public ethToZCZConversion = 1000;

  struct Album {
    uint16 albumId;
    uint16 nStickers;
    uint256 nStickersPerPack;
    uint256 packPrice;
    uint256 ethReceived;
    uint256 mintedCoins;
    uint256 burntCoins;
    uint256 nStickersInCirculation;
    uint256 nRewardedUsers;
    mapping(uint256=>uint256) stickersMap;
    mapping(uint256=>address) rewardedUsers;
    mapping(address=>uint256) rewardedEth;
    mapping(address=>uint256) rewardedCoinBurnt;
  }

  mapping (uint16 => Album) public albums;



  constructor(address _assetContractAddress, address _coinContractAddress) public {
    if (_assetContractAddress != address(0)) Frontend.changeAssetContract(_assetContractAddress);
    if (_coinContractAddress != address(0)) Frontend.changeCoinContract(_coinContractAddress);
  }

  /* MODIFIERS */
  modifier albumExist(uint16 _albumId){
    require(albums[_albumId].nStickers!=0, 'Album should exist');
    _;
  }

  /* INTERNALS */
  /**
   * @dev It randomly generates a new sticker identifier.
   * @param _albumId The unique id of the album.
   * @return _stickerId A new sticker identifier.
   */
  function _generateSticker(uint16 _albumId)
  internal
  returns(uint256)
  {
    uint256 _rnd = _generateSeed();
    bytes32 _stickerId = bytes32(bytes2(_albumId)) | bytes32(bytes30(_rnd))>>16;
    return uint256(_stickerId);
  }

  /**
   * @dev It retrieve all the sticker details, i.e. its album and sticker number.
   * @param _stickerId The unique id of the sticker.
   * @return _albumId The unique id of the album.
   * @return _stn The sticker number.
   * @return _sId The sticker unique fingerprint.
   */
  function _getStickerInfo(uint256 _stickerId)
  internal
  view
  returns(uint16 _albumId, uint16 _stn, uint256 _sId)
  {
    _albumId = uint16(bytes32(_stickerId) >> 240);
    _sId = uint256((bytes32(_stickerId) << 16) >> 16);
    _stn = _getStn(_albumId, _sId);
  }

  /**
   * @dev It calculates the sticker number in a way that guarantees artificial
   * scarcity of the low sticker numbers while preserving a smooth probability
   * distribution curve.
   * @param _albumId The unique id of the album.
   * @param _stickerId The unique id of the sticker.
   * @return _stn The sticker number.
   */
  function _getStn(uint16 _albumId, uint256 _stickerId)
  internal
  view
  returns(uint16 _stn)
  {
    assert(albums[_albumId].nStickers!=0);
    bytes32 _sId = bytes32(_stickerId<<16);
    /* Function for programmatical scarcity */
    //General formula is: _stn = a + b * c
    //where a = substring(_stickerId, 0) % N
    //where b = substring(_stickerId, 1) % (N/5)
    //where c = substring(_stickerId, 2) % 5

    uint16 _n = albums[_albumId].nStickers;
    uint16 _l = 5;              //This is the only hardcoded params and it gives pretty good scarcity within a range of 10-1000 stickers per album
    uint16 _m = (_n / _l);  //+1 to avoid zeroes

    uint256 _a = uint256(bytes10(_sId << 160)) % _n;
    uint256 _b = uint256(bytes10(_sId << 80)) % (_m + 1);
    uint256 _c = uint256(bytes10(_sId)) % (_l + 1);
    uint256 _o = _a + _b * _c;

    //Residuals are used to rebalance in case _stn >= N
    int256 _rs = int256(_o) - int256(_n);
    if (_rs>=0) _o = _n - 1 - uint256(_rs % _n);
    _stn = uint16(_o);
  }

  //PUBLIC VIEW FUNCTIONS
  /**
   * @dev It computes the expected reward in ZtickyCoinZ associated to a successful
   * sticker unwrap. It uses the real probability distribution of stickers in order
   * to determine the reward associated to the newly created sticker.
   * The more a sticker is rare, the more coins one will get as a reward.
   * @param _albumId The unique id of the album.
   * @param _stn The sticker number.
   * @return out The amount of coin reward expressed in ZCZ.
   */
  function computeCoinReward(uint16 _albumId, uint16 _stn)
  public
  view
  returns(uint256 out)
  {
    uint256 _supply = albums[_albumId].nStickersInCirculation;              //total Supply
    uint256 _scarcity = albums[_albumId].stickersMap[_stn]                //get real distribution coefficient. Scarcity = 1000 average. <1000 rare. >1000 common.
                        .mul(albums[_albumId].nStickers)                    //normalize by stickers in album
                        .add(1)                                             //avoid zeroes
                        .mul(1000)                                          //Damned unsupported floating operation
                        .div((_supply + 1));                                  //Calculate scarsity coefficient
    out = albums[_albumId].packPrice;                                       //Standardize accross albums by its pack price
    out = out.mul(ethToZCZConversion);                                     //Statistically stable conversion ratio 1ETH = 1000ZCZ or 1wei=1 000 000 000 000 000 000 000 ZCZ
    out = out.mul(1000);                                                   //Floating operation
    out = out.div(_scarcity);                                            //Divide by _scarcity. The more is rare, the more coins will get minted
    out = out.div(albums[_albumId].nStickersPerPack);                      //Divide equally among stickers in pack
  }

  /**
   * @dev It determines wheter the album of a given user has been successfully
   * completed by evaluating whether the user is in possession of all the stickers
   * with their corresponding sticker numbers that are needed to complete the album
   * @param _owner The user to be inspected.
   * @param _albumId The unique id of the album.
   * @return bool Wheter completed or not.
   */
  function isAlbumComplete(address _owner, uint16 _albumId)
  public
  view
  isFrontendConfigured
  albumExist(_albumId)
  returns(bool)
  {
    require(albums[_albumId].nStickers!=0, 'Should have stickers');
    uint256[] memory _stickers = assetContract.getStickersOf(_owner);
    uint256[] memory _orderedList = new uint256[](albums[_albumId].nStickers);
    uint16 counter=0;
    for (uint256 i = 0; i < _stickers.length ; i++) {
      uint16 _stn = _getStn(_albumId, _stickers[i]);
      if(counter==albums[_albumId].nStickers) break;
      if(_orderedList[_stn]!=0) continue;
      _orderedList[_stn] = _stickers[i];
      counter++;
    }
    if(counter==albums[_albumId].nStickers) return true;
    return false;
  }

  /**
   * @dev It gather all the sticker details associated to a sticker
   * @param _stickerId The unique id of the sticker.
   * @return _albumId The unique id of the album.
   * @return _stn The sticker number.
   * @return _sId The sticker unique fingerprint.
   * @return _owner The _owner address of the sticker.
   * @return _onSale Wheter is in the order book or not.
   * @return _onSalePrice The selling price in case is on sale.
   */
  function getStickerDetails(uint256 _stickerId)
  public
  view
  isFrontendConfigured
  returns(uint16 _albumId, uint16 _stn, uint256 _sId, address _owner, bool _onSale, uint256 _onSalePrice)
  {
    (_albumId, _stn, _sId) = _getStickerInfo(_stickerId);
    _owner = assetContract.ownerOf(_stickerId);
    _onSale = orderBook[_stickerId].seller!=address(0) ? true : false;
    _onSalePrice = orderBook[_stickerId].price;
  }

  /**
   * @dev It gather all the sticker details associated to an array of stickers
   * @param _stickerIds The array of unique ids of the sticker.
   * @return _albumId The unique id of the album.
   * @return _stn The sticker number.
   * @return _sId The sticker unique fingerprint.
   * @return _owner The _owner address of the sticker.
   * @return _onSale Wheter is in the order book or not.
   * @return _onSalePrice The selling price in case is on sale.
   */
  function getStickersDetails(uint256[] _stickerIds)
  public
  view
  returns (uint16[] _albumId, uint16[] _stn, uint256[] _sId, address[] _owner, bool[] _onSale, uint256[] _onSalePrice)
  {
    _albumId = new uint16[](_stickerIds.length);
    _stn = new uint16[](_stickerIds.length);
    _sId = new uint256[](_stickerIds.length);
    _owner = new address[](_stickerIds.length);
    _onSale = new bool[](_stickerIds.length);
    _onSalePrice = new uint256[](_stickerIds.length);
    for (uint i = 0; i < _stickerIds.length ; i++) {
      (uint16 _a, uint16 _b, uint256 _c, address _d, bool _e, uint256 _f) = getStickerDetails(_stickerIds[i]);
      _albumId[i] = _a;
      _stn[i] = _b;
      _sId[i] = _c;
      _owner[i] = _d;
      _onSale[i] = _e;
      _onSalePrice[i] = _f;
    }
    return (_albumId, _stn, _sId, _owner, _onSale, _onSalePrice);
  }

  /**
   * @dev It computes the statistics of an album
   * @param _albumId The unique id of the album.
   * @return _nStickers Number of sticker numbers in the allbum.
   * @return _nStickersPerPack Number of stickers unwrapped per pack.
   * @return _packPrice Pack price in wei.
   * @return _ethReceived The amount of ether received due to pack unwrapping.
   * @return _mintedCoins Amount of minted coins due to unwrap reward.
   * @return _burntCoins Amount of burnt coins due to album completion reward.
   * @return _nStickersInCirculation Total number of unique stickers generated by the album.
   * @return _stnDistribution Real distribution divided by sticker number.
   * @return _nextStnGenReward Next coin reward due to pack unwrap divided by sticker number.
   * @return _rewardedUsers List of rewarded address upon album completion.
   * @return _rewardedEth Amount of Eth prize received back upon album completion.
   * @return _rewardedCoinBurnt Amount of coin burnt upon album completion.
   */
  function getAlbumStats(uint16 _albumId)
  public
  view
  albumExist(_albumId)
  returns ( uint16 _nStickers,
            uint256 _nStickersPerPack,
            uint256 _packPrice,
            uint256 _ethReceived,
            uint256 _mintedCoins,
            uint256 _burntCoins,
            uint256 _nStickersInCirculation,
            uint256[] _stnDistribution,
            uint256[] _nextStnGenReward,
            address[] _rewardedUsers
            /* uint256[] _rewardedEth, */
            /* uint256[] _rewardedCoinBurnt */
            )
  {
    _nStickers = albums[_albumId].nStickers;
    _nStickersPerPack = albums[_albumId].nStickersPerPack;
    _packPrice = albums[_albumId].packPrice;
    _ethReceived = albums[_albumId].ethReceived;
    _mintedCoins = albums[_albumId].mintedCoins;
    _burntCoins = albums[_albumId].burntCoins;
    _nStickersInCirculation = albums[_albumId].nStickersInCirculation;

    _stnDistribution = new uint256[](albums[_albumId].nStickers);
    _nextStnGenReward = new uint256[](albums[_albumId].nStickers);
    _rewardedUsers = new address[](albums[_albumId].nRewardedUsers);
    /* _rewardedEth = new uint256[](albums[_albumId].nRewardedUsers); */
    /* _rewardedCoinBurnt = new uint256[](albums[_albumId].nRewardedUsers); */
    for (uint256 i = 0; i < albums[_albumId].nRewardedUsers ; i++) {
       _rewardedUsers[i] = albums[_albumId].rewardedUsers[i];
       /* _rewardedEth[i] = albums[_albumId].rewardedEth[_rewardedUsers[i]]; */
       /* _rewardedCoinBurnt[i] = albums[_albumId].rewardedCoinBurnt[_rewardedUsers[i]]; */
    }
    for (uint16 l = 0; l < albums[_albumId].nStickers ; l++) {
       _stnDistribution[l] = albums[_albumId].stickersMap[l];
       _nextStnGenReward[l] = computeCoinReward(_albumId, l);
    }
  }

  /**
   * @dev It computes the expected ether reward upon album completion.
   * That is paid using the ether balance stored within the contract and it is
   * calculated using a set of different parameters to align with proper playing incentives.
   * The reward is based on the amount of ZtickyCoinZ that the user aims to burn
   * and it varies based on some bonuses that are:
   * - A velocity reward ratio: that determines the speed of album completion
   * - A global supply reward ratio: that gives a reward based on the amount of coins to burn with respect to the total coin supply
   * @param _albumId The unique id of the album.
   * @param _coinToBurn The amount of coins to burn.
   * @return _eth The ether amount of the reward.
   * @return _tips The amount of tips due to developer.
   */
  function computeAlbumReward(uint16 _albumId, uint256 _coinToBurn)
  public
  view
  albumExist(_albumId)
  returns(uint256 _eth, uint256 _tips)
  {
    ///AVOID STACK TOO DEEP
    Album storage _a = albums[_albumId];
    uint256 _supply = coinContract.totalSupply();
    require(_a.mintedCoins.sub(_a.burntCoins)>_coinToBurn, 'Should not exceed maximum burnable');
    require(_coinToBurn>0, 'Should burn some coin');
    //aRatio
    uint256 _aRatio = _coinToBurn.mul(1000);                                    //0 >= album ratio on album <= 1000
            _aRatio = _aRatio.div(_a.mintedCoins - _a.burntCoins);
    //eRatio
    uint256 _eRatio = _a.ethReceived;                                           //0 >= eth ratio on album <= 1000
            _eRatio = _eRatio.mul(1000);
            _eRatio = _eRatio.div(totalEthReceived);
    //vrRatio
    uint256 _vrRatio = _coinToBurn.mul(2000);                                   //500 >= velocity reward ratio of album <= 2500
            _vrRatio = _vrRatio.div(_coinToBurn + _a.burntCoins);
            _vrRatio = _vrRatio.add(500);
    //srRatio
    uint256 _srRatio = _coinToBurn.mul(3000);                                   //500 >= global supply reward ratio <= 3500
            _srRatio = _srRatio.div(_supply);
            _srRatio = _srRatio.add(500);
    //total
    uint256 _total = address(this).balance
                              .mul(_eRatio)
                              .mul(_aRatio)
                              .mul(_vrRatio)
                              .mul(_srRatio)
                              .div(1000000000000);
    if(_total>address(this).balance) _total = address(this).balance;
    _eth  = _total.mul(95).div(100);
    _tips = _total.mul(5).div(100);                //tips for developers
  }

  //PUBLIC WRITE FUNCTIONS

  /**
   * @dev It creates a new sticker album and set its parameters.
   * @param _nS The number of stickers in the album.
   * @param _nSxPack The number of stickers generated by each pack unwrap.
   * @param _packPrice The price in wei of a pack.
   * @return albumCount The number of albums present in the contract.
   */
  function createAlbum(uint16 _nS, uint16 _nSxPack, uint256 _packPrice) //packPrice in wei
  public
  onlyOwner
  returns(uint16)
  {
    /* Check in case of integer overflow */
    require(uint16(albumCount + 1)>0 , 'Album integer overflow');
    require((_nS!=0) && (_nSxPack!=0), 'Should have sticker number and stickers per pack');
    albums[albumCount] = Album(albumCount, _nS, _nSxPack, _packPrice, 0, 0, 0, 0, 0);
    return albumCount++;
  }

  /**
   * @dev It buys a sticker pack and unwrap it generating n stickers as specified
   * for the album parameters.
   * @param _albumId The unique id of the album.
   * @return uint256[] An array of newly generated stickers.
   */
  function unwrapStickerPack(uint16 _albumId)
  public
  payable
  whenNotPaused
  isFrontendConfigured
  albumExist(_albumId)
  returns(uint256[])
  {
    require(albums[_albumId].packPrice==msg.value, 'Should pay the cost of a pack');
    uint256[] memory out = new uint256[](albums[_albumId].nStickersPerPack);
    uint256 _coinReward = 0;
    for(uint i = 0; i < albums[_albumId].nStickersPerPack ; i++){
      uint256 _stickerId = _generateSticker(_albumId);
      (uint16 _stn) = _getStn(_albumId, _stickerId);
      _coinReward += computeCoinReward(_albumId, _stn);
      albums[_albumId].stickersMap[_stn]++;
      albums[_albumId].nStickersInCirculation++;
      out[i]=_stickerId;
      assetContract.generateSticker(msg.sender, _stickerId);
      emit Zticker(msg.sender, _albumId, _stn, _stickerId);
    }
    emit Log('Total coin reward: ' , _coinReward);
    albums[_albumId].mintedCoins+=_coinReward;
    albums[_albumId].ethReceived+=msg.value;
    totalEthReceived+=msg.value;
    coinContract.mint(msg.sender,_coinReward);
    return out;
  }

  /**
   * @dev It serves to redeem the final ether reward upon album completion.
   * Having completed the album is a strict requirement and the function rewards
   * the user based on the amount of ZtickyCoinZ that the user decides to burn.
   * The user cannot burn more coins than those generated by the global stickers unwrapping
   * of the specific completed album.
   * The function also recognizes a 5% tip of the total reward to the developers.
   * @param _albumId The unique id of the album.
   * @param _coinToBurn Amount of ZtickyCoinZ to be burnt.
   * @return bool Whether successful or not.
   */
  function redeemReward(uint16 _albumId, uint256 _coinToBurn)
  public
  whenNotPaused
  isFrontendConfigured
  albumExist(_albumId)
  returns(bool)
  {
    //Verify completion
    require(isAlbumComplete(msg.sender,_albumId), 'Should have completed the album');
    //Compute reward
    (uint256 _ethReward, uint256 _tips) = computeAlbumReward(_albumId, _coinToBurn);
    //Adjust stats
    albums[_albumId].burntCoins.add(_coinToBurn);
    if(albums[_albumId].rewardedCoinBurnt[msg.sender]==0) {
      albums[_albumId].rewardedUsers[albums[_albumId].nRewardedUsers] = msg.sender;
      albums[_albumId].nRewardedUsers++;
    }
    albums[_albumId].rewardedEth[msg.sender] += (_ethReward + _tips);
    albums[_albumId].rewardedCoinBurnt[msg.sender] += _coinToBurn;
    emit AlbumComplete(msg.sender, _coinToBurn, (_ethReward + _tips));
    //Finalize transaction
    coinContract.burn(_coinToBurn);
    _sendTip(_tips);
    msg.sender.transfer(_ethReward);
    return true;
  }



 /**
  * @notice Fallback function - Called if other functions don't match call or
  * sent ether without data
  * Typically, called when invalid data is sent
  * Added so ether sent to this contract is reverted if the contract fails
  * otherwise, the sender's money is transferred to contract
  */
  function() public {
        revert();
    }
}
