/* eslint no-use-before-define: "warn" */
const fs = require("fs");
const chalk = require("chalk");
const { ethers, tenderly, run } = require("hardhat");
const { utils } = require("ethers");
const R = require("ramda");

const main = async () => {
	console.log("\n\n 📡 Deploying...\n");

	const metaMultiSigWallet = await deploy("MetaMultiSigWallet", [
		5,
		[
			"0x662C2e2F9C98150C20DDCe35df42f17b11C671df",
			"0xc3ef7bba19A079E226B9e0D8d91B95ee0a62dE49",
		],
		1,
	]);

	// If you want to verify your contract on etherscan
	console.log(chalk.blue("verifying on etherscan"));
	await run("verify:verify", {
		address: metaMultiSigWallet.address,
		constructorArguments: [
			5,
			[
				"0x662C2e2F9C98150C20DDCe35df42f17b11C671df",
				"0xc3ef7bba19A079E226B9e0D8d91B95ee0a62dE49",
			],
			1,
		],
	});

	console.log(
		" 💾  Artifacts (address, abi, and args) saved to: ",
		chalk.blue("packages/hardhat/artifacts/"),
		"\n\n"
	);
};

const deploy = async (
	contractName,
	_args = [],
	overrides = {},
	libraries = {}
) => {
	console.log(` 🛰  Deploying: ${contractName}`);

	const contractArgs = _args || [];
	const contractArtifacts = await ethers.getContractFactory(contractName, {
		libraries: libraries,
	});
	const deployed = await contractArtifacts.deploy(...contractArgs, overrides);
	console.log("Waiting for 5 block confirmations!");
	await deployed.deployed(5);
	console.log("Confirmation received!");
	const encoded = abiEncodeArgs(deployed, contractArgs);
	fs.writeFileSync(`artifacts/${contractName}.address`, deployed.address);

	let extraGasInfo = "";
	if (deployed && deployed.deployTransaction) {
		const gasUsed = deployed.deployTransaction.gasLimit.mul(
			deployed.deployTransaction.gasPrice
		);
		extraGasInfo = `${utils.formatEther(gasUsed)} ETH, tx hash ${
			deployed.deployTransaction.hash
		}`;
	}

	console.log(
		" 📄",
		chalk.cyan(contractName),
		"deployed to:",
		chalk.magenta(deployed.address)
	);
	console.log(" ⛽", chalk.grey(extraGasInfo));

	await tenderly.persistArtifacts({
		name: contractName,
		address: deployed.address,
	});

	if (!encoded || encoded.length <= 2) return deployed;
	fs.writeFileSync(`artifacts/${contractName}.args`, encoded.slice(2));

	return deployed;
};

// ------ utils -------

// abi encodes contract arguments
// useful when you want to manually verify the contracts
// for example, on Etherscan
const abiEncodeArgs = (deployed, contractArgs) => {
	// not writing abi encoded args if this does not pass
	if (
		!contractArgs ||
		!deployed ||
		!R.hasPath(["interface", "deploy"], deployed)
	) {
		return "";
	}
	const encoded = utils.defaultAbiCoder.encode(
		deployed.interface.deploy.inputs,
		contractArgs
	);
	return encoded;
};

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
