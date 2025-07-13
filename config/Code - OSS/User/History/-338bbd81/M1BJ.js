const hre = require("hardhat")

async function main() {
    const PlatformRegistry = await hre.ethers.getContractFactory(
			'PlatformRegistry'
		)
    const contract = await PlatformRegistry.deploy()

    await contract.waitForDeployment();
    console.log("Contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
    console.log(error);
    process.exitCode = 1;
})