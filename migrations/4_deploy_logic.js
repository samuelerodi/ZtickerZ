var ZtickyStake = artifacts.require("ZtickyStake");
var ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
var ZtickyBank = artifacts.require("ZtickyBank");
var ZtickerZ = artifacts.require("ZtickerZ");

module.exports = async function(deployer) {
  var accounts = await web3.eth.getAccounts();
  var z = await deployer.deploy(ZtickerZ, {from: accounts[0]});
};
