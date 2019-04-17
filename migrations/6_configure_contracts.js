var ZtickyStake = artifacts.require("ZtickyStake");
var ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
var ZtickyBank = artifacts.require("ZtickyBank");
var ZtickerZ = artifacts.require("ZtickerZ");

module.exports = async function(deployer) {
  var accounts = await web3.eth.getAccounts();
  var z = await ZtickerZ.deployed();
  var zcz = await ZtickyCoinZ.deployed();
  var zstake = await ZtickyStake.deployed();
  var zbank = await ZtickyBank.deployed();
  await zcz.addFrontend(z.address, {from: accounts[1]});
  await zstake.addFrontend(z.address, {from: accounts[1]});
  await zbank.addFrontend(z.address, {from: accounts[1]});
  await z.changeZCZContract(zcz.address, {from: accounts[1]});
  await z.changeZStakeContract(zstake.address, {from: accounts[1]});
  await z.changeZBankContract(zbank.address, {from: accounts[1]});
};
