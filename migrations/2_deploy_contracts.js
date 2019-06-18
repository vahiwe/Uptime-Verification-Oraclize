const UptimeVerification = artifacts.require("UptimeVerification");

module.exports = function(deployer) {
  deployer.deploy(UptimeVerification);
};
