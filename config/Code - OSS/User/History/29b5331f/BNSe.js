const hre = require("hardhat");

async function main() {
    const contractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
    const contract = await hre.ethers.getContractAt(
			'HelloWorld',
			contractAddress
		);

    await contract.
}