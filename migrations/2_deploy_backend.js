var ZtickyStake = artifacts.require("ZtickyStake");
var ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
var ZtickyBank = artifacts.require("ZtickyBank");
var ZtickerZ = artifacts.require("ZtickerZ");

module.exports = async function(deployer) {
  var accounts = await web3.eth.getAccounts();
  var zcz = await deployer.deploy(ZtickyCoinZ, "https://ztickerz.io", {from: accounts[0]});
  var zstake = await deployer.deploy(ZtickyStake, ZtickyCoinZ.address, {from: accounts[0]});
  var zbank = await deployer.deploy(ZtickyBank, ZtickyCoinZ.address, {from: accounts[0]});
};
