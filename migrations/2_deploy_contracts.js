const UptimeVerification = artifacts.require("./UptimeVerification.sol");

module.exports = function(deployer) {
  deployer.deploy(UptimeVerification);
};
