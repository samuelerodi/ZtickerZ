var Migrations = artifacts.require("Migrations");

module.exports = async function(deployer) {
  var migrations = await deployer.deploy(Migrations);
};
