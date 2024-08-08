const BlockBet = artifacts.require("BlockBet");

module.exports = function(deployer) {
  deployer.deploy(BlockBet);
};
