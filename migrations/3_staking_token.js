const StakingToken = artifacts.require("StakingToken");

module.exports = function (deployer) {
  deployer.deploy(StakingToken, '0x2E8c278DfEB5C9a087677E4609307152398B361a', 1000);
};
