const hre = require("hardhat");

async function main() {
    const contract = await hre.ethers.getContractAt(
			'HelloWorld',
			0x5fbdb2315678afecb367f032d93f642f64180aa3
		)
}