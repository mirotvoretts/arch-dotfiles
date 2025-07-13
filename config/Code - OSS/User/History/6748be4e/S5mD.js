const hre = require("hardhat")

async function main() {
    const TodoList = await hre.ethers.getContractFactory('TodoList')
    const contract = await TodoList.deploy()

    await contract.waitForDeployment();

    console.log("Contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})