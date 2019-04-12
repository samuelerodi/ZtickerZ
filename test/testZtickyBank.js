const ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
const ZtickyStake = artifacts.require("ZtickyStake");
const ZtickyBank = artifacts.require("ZtickyBank");
const ZtickerZ = artifacts.require("ZtickerZ");

const BN = web3.utils.BN;

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

contract('ZtickyBank', function(accounts) {
   before("...should set the instances.", async function(){
     zstake = await ZtickyStake.deployed()
     zcz = await ZtickyCoinZ.deployed()
     zbank = await ZtickyBank.deployed()
     z = await ZtickerZ.deployed()
   });

   it("...should be a configured Backend.", async function() {
     var t = await zcz.frontendActivationTime();
     assert.equal(await zcz.isFrontend(accounts[0]), false, "Account 0 must not be a valid frontend");
     await zcz.addFrontend(accounts[0], {from:accounts[0]});
     await sleep(parseInt(t.toString()) * 1100); //Wait a little more to let block formation
     assert.equal(await zcz.isFrontend(accounts[0]), true, "Now it must be a valid frontend");
   });

  it("...should have a correct balance.", async function() {
    var a = await zbank.totalBalance();
    assert.equal(a[0].toString(), _zero.toString(), "It should have no ether");
    assert.equal(a[1].toString(), _zero.toString(), "It should have no tokens");
    await zbank.send(_eth,{from: accounts[0]});
    var _2eth = _eth.mul(new BN(2));
    await zcz.mint(zbank.address, _2eth, {from:accounts[0]});
    var a = await zbank.totalBalance();
    assert.equal(a[0].toString(), _eth.toString(), "It should have some ether");
    assert.equal(a[1].toString(), _2eth.toString(), "It should have some tokens");
  });

  it("...should have correct dividends.", async function() {
    var a = await zbank.outstandingDividendsPerShare();
    assert.equal(a[0].toString(), "1", "It should have 1 wei as payable");
    assert.equal(a[1].toString(), "2", "It should have 2 zcz as payable");
    var _mil = new BN(1000);
    var a = await zbank.outstandingDividendsFor(_mil);
    assert.equal(a[0].toString(), _mil.toString(), "It should have correct wei as payable");
    assert.equal(a[1].toString(), _mil.mul(new BN(2)).toString(), "It should have correct zcz as payable");
  });

  it("...should stake.", async function() {
    await zcz.mint(accounts[3], _eth, {from:accounts[0]});
    await zcz.mint(accounts[4], _eth, {from:accounts[0]});
    await z.stake(_eth, {from: accounts[3]});
    await z.stake(_eth, {from: accounts[4]});
    await sleep(10000);
    var s = await zstake.sharesOf(accounts[3]);
    var st = await zstake.totalStakedFor(accounts[4]);
    assert.equal(st.gt(new BN(0)), true, "It should have staked");
    assert.equal(s.gte(_eth.div(new BN(2))), true, "It should have staked correctly");
  });

  it("...should pay out expected dividends.", async function() {
    var m = await zstake.maturedTokensOf(accounts[4]);
    assert.equal(m.toString(), _eth.toString(), "It should have some matured tokens");
    var s1 = await zstake.sharesOf(accounts[4]);
    var st1 = await zstake.totalStakedFor(accounts[4]);
    var b1 = await zcz.balanceOf(accounts[4]);
    var d1 = await zbank.outstandingDividendsFor(s1);
    await z.claimDividendsAndRestake({from: accounts[4]});
    var s2 = await zstake.sharesOf(accounts[4]);
    var st2 = await zstake.totalStakedFor(accounts[4]);
    var b2 = await zcz.balanceOf(accounts[4]);
    var d2 = await zbank.outstandingDividendsFor(s2);
    assert.equal(s1.gt(s2), true, "It should have burnt some shares");
    assert.equal(st1.toString(), st2.toString(), "It should have restaked the same amount");
    assert.equal(b2.add(d1[1]).gt(b1), true, "It should have received some dividends");
    assert.equal(d1[1].gt(d2[1]), true, "It should have no more dividends by now");
  });

  it("...should stake for someone else.", async function() {
    var b1 = await zcz.balanceOf(accounts[6]);
    assert.equal(b1.toString(), "0", "It should have no coins 1");
    await zcz.mint(accounts[5], _eth, {from:accounts[0]});
    await z.stakeFor(accounts[6], _eth, {from: accounts[5]});
    var b2 = await zcz.balanceOf(accounts[5]);
    assert.equal(b2.toString(), "0", "It should also have no coins 1");
    var st1 = await zstake.totalStakedFor(accounts[5]);
    var st2 = await zstake.totalStakedFor(accounts[6]);
    assert.equal(st1.toString(), "0", "It should have staked correctly 1");
    assert.equal(st2.toString(), _eth.toString(), "It should have staked correctly 2");
    await sleep(10000);
    var s1 = await zstake.sharesByFor(accounts[5],accounts[6]);
    var d1 = await zbank.outstandingDividendsFor(s1);
    var b1 = await zcz.balanceOf(accounts[6]);
    var b2 = await zcz.balanceOf(accounts[5]);
    assert.equal(b1.toString(), "0", "It should have no coins 2");
    assert.equal(s1.gt(new BN(0)), true, "It should have some shares");
    assert.equal(d1[1].gt(new BN(0)), true, "It should still have some dividends left");
    await z.unstakeFor(accounts[6], _eth, {from: accounts[5]});
    var b1 = await zcz.balanceOf(accounts[6]);
    var b2 = await zcz.balanceOf(accounts[5]);
    assert.equal(b1.gte(d1[1]), true, "It should have received some dividends");
    assert.equal(b2.toString(), _eth.toString(), "It should have got back is money");
    var s1 = await zstake.sharesOf(accounts[6]);
    var st1 = await zstake.totalStakedFor(accounts[6]);
    var st2 = await zstake.totalStakedFor(accounts[5]);
    assert.equal(s1.toString(), _zero.toString(), "It should have no more shares");
    assert.equal(st1.toString(), _zero.toString(), "It should have nothing more at stake");
    assert.equal(st2.toString(), _zero.toString(), "It should have nothing more at stake");
  });

  it("...should empty the pot.", async function() {
    var a = await zbank.totalBalance();
    assert.equal(a[0].gt(new BN(0)), true, "It should still have some ether");
    assert.equal(a[1].gt(new BN(0)), true, "It should still have some tokens");
    await z.unstake(_eth, {from: accounts[3]});
    await z.unstake(_eth, {from: accounts[4]});
    var st = await zstake.totalStaked();
    assert.equal(st.toString(), "0", "It should have nothing at stake");
    var a = await zbank.totalBalance();
    assert.equal(a[0].toString(), "0", "It should have taken ether");
    assert.equal(a[1].toString(), "0", "It should have taken tokens");
  })

  // function outstandingDividendsPerShare() external view returns (uint256, uint256);
  // function outstandingDividendsFor(uint256 shares) external view returns (uint256, uint256);
  // function payout(address payable to, uint256 shares) external returns (bool);
})
