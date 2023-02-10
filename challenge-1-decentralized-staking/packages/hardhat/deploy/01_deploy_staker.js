// deploy/01_deploy_staker.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  const exampleExternalContract = await ethers.getContract(
    "ExampleExternalContract",
    deployer
  );

  await deploy("Staker", {
    from: deployer,
    args: [exampleExternalContract.address],
    log: true,
  });

  const Staker = await ethers.getContract("Staker", deployer);

  // todo: uncomment to verify your contract
  if (chainId !== "31337") {
    try {
      console.log(" 🎫 Verifing Contract on Etherscan... ");
      await sleep(3000); // wait 3 seconds for deployment to propagate bytecode
      await run("verify:verify", {
        address: Staker.address,
        contract: "contracts/Staker.sol:Staker",
        constructorArguments: [exampleExternalContract.address],
      });
    } catch (e) {
      console.log(" ⚠️ Failed to verify contract on Etherscan ");
    }
  }
};

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

module.exports.tags = ["Staker"];
