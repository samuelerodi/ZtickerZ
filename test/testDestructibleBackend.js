const ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
const ZtickyStake = artifacts.require("ZtickyStake");
const ZtickyBank = artifacts.require("ZtickyBank");
const ZtickerZ = artifacts.require("ZtickerZ");

const a1 = web3.utils.toBN("1000000");
const a2 = web3.utils.toBN("500000");
const a3 = web3.utils.toBN("200000");
const a4 = web3.utils.toBN("600000");
const _b = web3.utils.toBN("1000");
const _zero = web3.utils.toBN("0");
const _eth = web3.utils.toBN(web3.utils.toWei("1"));

const sleep = (milliseconds) => {
  console.log("Waiting... " + milliseconds + " ms");
  return new Promise(resolve => setTimeout(resolve, milliseconds))
}

var zstake, zcz, z;
// var accounts; web3.eth.getAccounts().then(r=>accounts=r)

contract('Backend', function(accounts) {
   before("...should set the instances.", async function(){
     zstake = await ZtickyStake.deployed()
     zcz = await ZtickyCoinZ.deployed()
     zbank = await ZtickyBank.deployed()
     z = await ZtickerZ.deployed()
   });

  it("...should be a configured Backend.", async function() {
    assert.equal(await zcz.isBackend(), true, "it must be a backend contract");
    var t = await zcz.frontendActivationTime();
    assert.equal(await zcz.isFrontend(accounts[0]), false, "Account 0 must not be a valid frontend");
    await zcz.addFrontend(accounts[0], {from:accounts[0]});
    assert.equal(await zcz.isFrontend(accounts[0]), false, "Should still be not be a valid frontend");
    await sleep(parseInt(t.toString()) * 1100); //Wait a little more to let block formation
    assert.equal(await zcz.isFrontend(accounts[0]), true, "Now it must be a valid frontend");
  });

  it("...should mint some coins.", async function() {
    await zcz.mint(zbank.address, a1, {from:accounts[0]});
    assert.equal((await zcz.balanceOf(zbank.address)).toString(), a1.toString(), "Should have minted coins");
    await zcz.mint(zstake.address, a1, {from:accounts[0]});
    assert.equal((await zcz.balanceOf(zstake.address)).toString(), a1.toString(), "Should have minted coins");
  });

  it("...should set a backend admin.", async function() {
    assert.equal(await zstake.isBackendAdmin(accounts[1]), false, "It must not be a backend admin");
    await zstake.addBackendAdmin(accounts[1], {from:accounts[0]});
    assert.equal(await zstake.isBackendAdmin(accounts[1]), true, "It must now be a backend admin");
    assert.equal(await zbank.isBackendAdmin(accounts[1]), false, "It must not be a backend admin");
    await zbank.addBackendAdmin(accounts[1], {from:accounts[0]});
    assert.equal(await zbank.isBackendAdmin(accounts[1]), true, "It must now be a backend admin");
  });

  it("...should pause the contract.", async function() {
    assert.equal(await zstake.paused(), false, "It should not be paused");
    await zstake.pause({from:accounts[0]});
    assert.equal(await zstake.paused(), true, "It should be paused");
  });

  it("...should not be able to destroy and send.", async function() {
    var b = await zcz.balanceOf(accounts[3]);
    assert.equal((await zcz.balanceOf(accounts[3])).toString(), _zero.toString(), "It never received tokens");
    var e = false;
    try { await zstake.destroyAndSend(accounts[3],{from: accounts[1]}); }
    catch (err) { e = true; }
    assert.equal(e, true, "it should throw an error when invoked on non-paused contract");
  });

  it("...owner should be able to destroy and send.", async function() {
    await zstake.destroyAndSend(accounts[3],{from: accounts[0]});
    assert.equal((await zcz.balanceOf(accounts[3])).toString(), a1.toString(), "It should have been destroyed");
  });

  it("...should be able to destroy and refund owner.", async function() {
    var b1 = await zcz.balanceOf(accounts[0]);
    var c1 = await zcz.balanceOf(zbank.address);
    await zbank.pause({from:accounts[0]});
    await zbank.destroy({from: accounts[1]});
    var b2 = await zcz.balanceOf(accounts[0]);
    assert.equal(b1.add(c1).toString(), b2.toString(), "It should have been destroyed");
  });

 })
