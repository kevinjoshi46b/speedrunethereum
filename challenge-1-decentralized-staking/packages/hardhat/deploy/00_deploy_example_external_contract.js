// deploy/00_deploy_example_external_contract.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  await deploy("ExampleExternalContract", {
    from: deployer,
    log: true,
  });

  const exampleExternalContract = await ethers.getContract(
    "ExampleExternalContract",
    deployer
  );

  // todo: verification with etherscan
  // Verification
  if (chainId !== "31337") {
    try {
      console.log(" 🎫 Verifing Contract on Etherscan... ");
      await sleep(5000); // wait 5 seconds for deployment to propagate
      await run("verify:verify", {
        address: exampleExternalContract.address,
        contract:
          "contracts/ExampleExternalContract.sol:ExampleExternalContract",
      });
    } catch (error) {
      console.log("⚠️ Contract Verification Failed: ", error);
    }
  }
};

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

module.exports.tags = ["ExampleExternalContract"];
