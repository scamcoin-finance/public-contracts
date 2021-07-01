const StakingToken = artifacts.require("StakingToken");
const ISO = artifacts.require("ISO");

module.exports = function(deployer) {
  deployer.deploy(StakingToken);
  deployer.deploy(ISO);
};
