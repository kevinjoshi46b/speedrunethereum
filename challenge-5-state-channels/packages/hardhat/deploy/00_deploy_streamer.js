// deploy/00_deploy_streamer.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  await deploy("Streamer", {
    from: deployer,
    log: true,
    waitConfirmations: 5,
  });

  const streamer = await ethers.getContract("Streamer", deployer);

  if (chainId !== "31337") {
    try {
      console.log(" 🎫 Verifing Contract on Etherscan... ");
      await run("verify:verify", {
        address: streamer.address,
        contract: "contracts/Streamer.sol:Streamer",
      });
    } catch (e) {
      console.log(" ⚠️ Failed to verify contract on Etherscan ");
    }
  }
};

module.exports.tags = ["Streamer"];
