const UptimeVerification = artifacts.require("./UptimeVerification.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(
    UptimeVerification, { from: accounts[5], gas:6721975, value: 50000000000000000000 });
};
