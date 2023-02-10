const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  await deploy("DiceGame", {
    from: deployer,
    value: ethers.utils.parseEther(".05"),
    log: true,
  });

  // Getting a previously deployed contract
  const diceGame = await ethers.getContract("DiceGame", deployer);

  // ToDo: Verify your contract with Etherscan for public chains
  if (chainId !== "31337") {
    try {
      console.log(" 🎫 Verifing Contract on Etherscan... ");
      await sleep(60000);
      await run("verify:verify", {
        address: diceGame.address,
        contract: "contracts/DiceGame.sol:DiceGame",
      });
    } catch (e) {
      console.log(" ⚠️ Failed to verify contract on Etherscan ");
    }
  }
};

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

module.exports.tags = ["DiceGame"];
