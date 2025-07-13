const hre = require("hardhat")

async function main() {
    const HelloWorld = await hre.ethers.getContractFactory("HelloWorld");
    const contract = await HelloWorld.deploy();

    await contract.waitForDeployment();

    console.log("");
}