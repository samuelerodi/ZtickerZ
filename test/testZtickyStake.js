const ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
const ZtickyStake = artifacts.require("ZtickyStake");
const ZtickerZ = artifacts.require("ZtickerZ");

const a1 = web3.utils.toBN("1000000");
const a2 = web3.utils.toBN("500000");
const a3 = web3.utils.toBN("200000");
const a4 = web3.utils.toBN("600000");
const _b = web3.utils.toBN("1000");
const _eth = web3.utils.toBN(web3.utils.toWei("1"));

var zstake, zcz, z;
// var accounts; web3.eth.getAccounts().then(r=>accounts=r)

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
    assert.equal((await zcz.balanceOf(accounts[0])).toNumber(), a1.toNumber(), "it must have received tokens");
  });

  it("...should stake some coins.", async function() {
    assert.equal(await zstake.totalStaked(), 0, "it must have nothing at stake");
    assert.equal((await zcz.balanceOf(accounts[0])).toNumber(), a1.toNumber(), "it must have something to stake");
    assert.equal(a1.toNumber()>=a2.toNumber(), true, "it must have enough to stake");
    await zcz.approve(zstake.address, a2, {from: accounts[0]});
    await zstake.stake(a2, {from: accounts[0]});
    assert.equal((await zstake.totalStakedFor(accounts[0])).toNumber(), a2.toNumber(), "it must have something at stake");
  });

  it("...should stake some more coins.", async function() {
    assert.equal((await zcz.balanceOf(accounts[0])).toNumber()>=a3.toNumber(), true, "it must have enough to stake");
    await z.stake(a3, {from: accounts[0]});
    assert.equal((await zstake.totalStakedFor(accounts[0])).toNumber() == (a2.toNumber()+a3.toNumber()), true, "it must have staked enough");
    var sr0 = await zstake.shareRatioOf(accounts[0]);
    assert.equal(sr0.toString(), _eth.toString(), "it should have all the shares");
  });

  it("...should stake some coins to a different users.", async function() {
    await z.mint(accounts[1], a1, {from: accounts[0]});
    assert.equal((await zcz.balanceOf(accounts[1])).toNumber()>=a2.toNumber(), true, "it must have minted some");
    await z.stake(a2, {from: accounts[1]});
    assert.equal((await zstake.totalStakedFor(accounts[1])).toString(), a2.toString(), "it must have staked enough coins");
  });

  it("...should have a share ratio.", async function() {
    assert.equal((await zstake.totalShares()).toNumber()>=0, true, "there should be something at stake");
    assert.equal((await zstake.sharesOf(accounts[0])).toNumber()>=0, true, "it should have something at stake");
    assert.equal((await zstake.sharesOf(accounts[1])).toNumber()>=0, true, "it should have something at stake");
    var sr0 = await zstake.shareRatioOf(accounts[0]);
    var sr1 = await zstake.shareRatioOf(accounts[1]);
    assert.equal(sr0.gt(sr1), true, "0 should have more share than 1");
    var r0 = a1.add(a2).mul(_b).div(a1.add(a2.add(a2)));
    var r1 = a2.mul(_b).div(a1.add(a2.add(a2)));
    assert.equal(sr0.mul(_b).div(_eth).gt(r0), true, "0 have started staking before 1");
    assert.equal(sr1.mul(_b).div(_eth).lt(r1), true, "1 have started staking after 0");
  });

  it("...should return correct tokens at maturity.", async function() {
    //No minimumLockTime set!
    var s0 = await zstake.totalStakedFor(accounts[0]);
    var m0 = await zstake.stakedTokenAtMaturity(accounts[0],accounts[0]);
    assert.equal(s0.toString(), m0.toString(), "it should be the same for minimumLockTime=0");
    var s1 = await zstake.totalStakedFor(accounts[1]);
    var m1 = await zstake.stakedTokenAtMaturity(accounts[1],accounts[1]);
    assert.equal(s1.toString(), m1.toString(), "it should be the same for minimumLockTime=0");
  });

  it("...should set minimumLockTime.", async function() {
    await zstake.changeMinimumLockTime(a1, {from: accounts[1]});
    var m = await zstake.minimumLockTime();
    assert.equal(m.toString(), a1.toString(), "it should have set the minimumLockTime");
  });

  it("...should now have 0 matured tokens.", async function() {
    //No minimumLockTime set!
    var s0 = await zstake.totalStakedFor(accounts[0]);
    var m0 = await zstake.stakedTokenAtMaturity(accounts[0],accounts[0]);
    var r0 = await zstake.shareRatioAtMaturity(accounts[0],accounts[0]);
    assert.notEqual(s0.toString(), "0", "it should still have something at stake");
    assert.equal(m0.toString(), "0", "but no matured token");
    assert.equal(r0.toString(), "0", "and no matured share ratio");
    var s1 = await zstake.totalStakedFor(accounts[1]);
    var m1 = await zstake.stakedTokenAtMaturity(accounts[1],accounts[1]);
    var r1 = await zstake.shareRatioAtMaturity(accounts[1],accounts[1]);
    assert.notEqual(s1.toString(), "0", "it should be the same for 1");
    assert.equal(m1.toString(), "0", "it should be the same for 1");
    assert.equal(r1.toString(), "0", "it should be the same for 1");

  });

  it("...should unstake some coins.", async function() {
    var b1 = await zcz.balanceOf(accounts[0]);
    var s1 = await zstake.totalStakedFor(accounts[0]);
    await z.unstake(a4, {from: accounts[0]});
    var b2 = await zcz.balanceOf(accounts[0]);
    var s2 = await zstake.totalStakedFor(accounts[0]);
    assert.equal(b2.gt(b1), true, "it must have unstaked some coins");
    assert.equal(s2.add(a4).toString(),s1.toString(), "it must have unstaked exact coins");
    assert.equal(b1.add(a4).toString(),b2.toString(), "it must have received exact coins");
  });

  it("...should destroy the contract.", async function() {
    var tStaked = await zstake.totalStaked();
    var e = false;
    try { await zstake.destroy({from: accounts[1]}); }
    catch (err) { e = true; }
    assert.equal(e, true, "it should throw an error when invoked on non-paused contract");
    await zstake.pause({from: accounts[1]});
    e = false;
    try { await zstake.destroyAndSend(accounts[3],{from: accounts[1]}); }
    catch (err) { e = true; }
    assert.equal(e, true, "it should throw an error when invoked by non legit owner");
    await zstake.destroyAndSend(accounts[3],{from: accounts[0]});
    var nBalance = await zcz.balanceOf(accounts[3]);
    assert.equal(nBalance.toString(),tStaked.toString(), "it should have sent the coins to the specified recipient");
  });

 })
