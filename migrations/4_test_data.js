var ZtickyStake = artifacts.require("ZtickyStake");
var ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
var ZtickyBank = artifacts.require("ZtickyBank");
var ZtickerZ = artifacts.require("ZtickerZ");

const POPULATE_TEST_DATA = false;


const a1 = web3.utils.toBN(web3.utils.toWei("1000"));
const a2 = web3.utils.toBN(web3.utils.toWei("5"));
const a3 = web3.utils.toBN(web3.utils.toWei("1"));

module.exports = async function(deployer) {
  var z = await ZtickerZ.deployed();
  var zcz = await ZtickyCoinZ.deployed();
  var zstake = await ZtickyStake.deployed();
  var zbank = await ZtickyBank.deployed();
  var accounts = await web3.eth.getAccounts();

  if (deployer.network_id == 100 && POPULATE_TEST_DATA) {
    console.log("Populating with test data!");
    //LOCAL NETWORK RUN
    await zcz.addBackendAdmin(accounts[1], {from: accounts[0]});
    await zstake.addBackendAdmin(accounts[1], {from: accounts[0]});
    await zcz.addPauser(accounts[1], {from: accounts[0]});
    await zstake.addPauser(accounts[1], {from: accounts[0]});

    await z.mint(accounts[0], a1, {from: accounts[0]});
    await zcz.transfer(accounts[1], a2,  {from: accounts[0]});
    await zcz.transfer(accounts[1], a2,  {from: accounts[0]});
    await zcz.transfer(accounts[2], a2,  {from: accounts[0]});
    await zcz.transfer(accounts[3], a2,  {from: accounts[0]});
    await zcz.transfer(accounts[4], a2,  {from: accounts[0]});
    await z.stake(a3, {from: accounts[0]});
    await z.stake(a2, {from: accounts[0]});
    await z.stake(a3, {from: accounts[0]});
    await z.stake(a2, {from: accounts[1]});
    await z.stake(a3, {from: accounts[1]});
    await z.stake(a3, {from: accounts[2]});
    await zstake.changeVestingTime(web3.utils.toBN("100"), {from: accounts[1]});
    await z.unstake(a2, {from: accounts[0]});
    await z.unstake(a3, {from: accounts[1]});
    await z.unstake(a3, {from: accounts[1]});
    await z.unstake(a3, {from: accounts[1]});
    await z.unstake(a3, {from: accounts[0]});

  }
}
