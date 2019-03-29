var ZtickyStake = artifacts.require("ZtickyStake");
var ZtickyCoinZ = artifacts.require("ZtickyCoinZ");
var ZtickerZ = artifacts.require("ZtickerZ");

module.exports = async function(deployer) {
  var zcz = await deployer.deploy(ZtickyCoinZ, "https://ztickerz.io");
  var zstake = await deployer.deploy(ZtickyStake, ZtickyCoinZ.address);
  var z = await deployer.deploy(ZtickerZ);
};
