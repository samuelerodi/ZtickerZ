var ZtickyStake = artifacts.require("ZtickyStake");
var ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
var ZtickerZ = artifacts.require("ZtickerZ");

module.exports = async function(deployer) {
  var cc, ac, zz;
  var z = await ZtickerZ.deployed();
  var zcz = await ZtickyCoinZ.deployed();
  var zstake = await ZtickyStake.deployed();
  var accounts = await web3.eth.getAccounts();
  await zcz.addFrontend(z.address, {from: accounts[0]});
  await zstake.addFrontend(z.address, {from: accounts[0]});
  await z.changeZCZContract(zcz.address, {from: accounts[0]});
  await z.changeZStakeContract(zstake.address, {from: accounts[0]});
};
