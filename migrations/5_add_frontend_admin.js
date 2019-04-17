var ZtickyStake = artifacts.require("ZtickyStake");
var ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
var ZtickyBank = artifacts.require("ZtickyBank");
var ZtickerZ = artifacts.require("ZtickerZ");

module.exports = async function(deployer) {
  var accounts = await web3.eth.getAccounts();
  var z = await ZtickerZ.deployed();
  await z.addFrontendAdmin(accounts[1], {from: accounts[0]});
};
