const UptimeVerification = artifacts.require("./UptimeVerification.sol");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(
      UptimeVerification, { from: accounts[0], gas:6721975, value: 5000000000000000000 });
  };
