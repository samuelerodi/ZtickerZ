var Migrations = artifacts.require("Migrations");

module.exports = async function(deployer) {
  var accounts = await web3.eth.getAccounts();
  console.log("\t-----\nUsing accounts list:");
  console.log(accounts)
  // var migrations = await deployer.deploy(Migrations, {from:accounts[0]});
};
