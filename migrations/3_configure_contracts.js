var SimpleStorage = artifacts.require("SimpleStorage");
var TutorialToken = artifacts.require("TutorialToken");
var ComplexStorage = artifacts.require("ComplexStorage");
//useless

var ZtickyZtorage = artifacts.require("ZtickyZtorage");
var ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
var ZtickerZ = artifacts.require("ZtickerZ");

module.exports = function(deployer) {
  var cc, ac, zz;
  return ZtickyZtorage.deployed()
    .then(r => {ac=r; return ZtickyCoinZ.deployed();})
    .then(r => {cc=r; return ZtickerZ.deployed();})
    .then(r => zz = r)
    .then(r => ac.changeFrontend(zz.address, {from: web3.eth.accounts[0]}))
    .then(r => cc.changeFrontend(zz.address, {from: web3.eth.accounts[0]}))
    .then(r => zz.createAlbum(100, 5, 0.01, {from: web3.eth.accounts[0]}));
};
