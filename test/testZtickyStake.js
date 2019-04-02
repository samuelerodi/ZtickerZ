const ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
const ZtickyStake = artifacts.require("ZtickyStake");
const ZtickerZ = artifacts.require("ZtickerZ");

const a1 = web3.utils.toBN("1000000");
const a2 = web3.utils.toBN("500000");
const a3 = web3.utils.toBN("200000");

var zstake, zcz, z;

contract('ZtickyStake', function(accounts) {
   before("...should set the instances.", async function(){
     zstake = await ZtickyStake.deployed()
     zcz = await ZtickyCoinZ.deployed()
     z = await ZtickerZ.deployed()
   });

  it("...should be a configured Backend.", async function() {
    assert.equal(await zstake.isBackend(), true, "it must be a backend contract");
    assert.equal(await zstake.isFrontend(z.address), true, "Frontend must be configured pointing to ZtickerZ contract");
    assert.equal(await zstake.isFrontend(zcz.address), false, "Frontend must not point to contracts else than ZtickerZ");
  });

  it("...should have a configured Frontend.", async function() {
    assert.equal(await z.isBackendConfigured(), true, "it must be a configured frontend");
  });

  it("...should have a Backend Admin.", async function() {
    assert.equal(await zstake.isBackendAdmin(accounts[0]), true, "it must be a backend admin");
    assert.equal(await zstake.isBackendAdmin(accounts[1]), false, "it must not be a backend admin");
    await zstake.addBackendAdmin(accounts[1], {from: accounts[0]});
    assert.equal(await zstake.isBackendAdmin(accounts[1]), true, "it must now be a backend admin");
  });

  it("...should have a pauser.", async function() {
    assert.equal(await zstake.isPauser(accounts[0]), true, "it must be a pauser");
    assert.equal(await zstake.isPauser(accounts[1]), false, "it must not be a pauser");
    await zstake.addPauser(accounts[1], {from: accounts[0]});
    assert.equal(await zstake.isPauser(accounts[1]), true, "it must now be a pauser");
  });

  it("...should be pausable.", async function() {
    assert.equal(await zstake.paused(), false, "it must not be paused yet");
    await zstake.pause({from: accounts[1]});
    assert.equal(await zstake.paused(), true, "now it must be paused");
    await zstake.unpause({from: accounts[0]});
    assert.equal(await zstake.paused(), false, "it must not be paused");
  });

  it("...should mint some coins.", async function() {
    await z.mint(accounts[0], a1, {from: accounts[0]});
    assert.equal((await zcz.balanceOf(accounts[0])).toString(), a1, "it must have received tokens");
  });

  it("...should stake some coins.", async function() {
    assert.equal(await zstake.totalStaked(), 0, "it must have nothing at stake");
    await z.stake(a2, {from: accounts[1]});
    assert.equal((await zstake.totalStaked()).toString(), a2, "it must have something at stake");
  });
 })
