var ZtickyStake = artifacts.require("ZtickyStake");
var ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
var ZtickyBank = artifacts.require("ZtickyBank");
var ZtickerZ = artifacts.require("ZtickerZ");

module.exports = async function(deployer) {
  var accounts = await web3.eth.getAccounts();
  var zcz = await ZtickyCoinZ.deployed();
  var zstake = await ZtickyStake.deployed();
  var zbank = await ZtickyBank.deployed();
  await zcz.addBackendAdmin(accounts[1], {from: accounts[0]});
  await zstake.addBackendAdmin(accounts[1], {from: accounts[0]});
  await zbank.addBackendAdmin(accounts[1], {from: accounts[0]});
};
