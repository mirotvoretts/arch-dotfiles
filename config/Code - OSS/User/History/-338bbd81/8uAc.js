const hre = require("hardhat")

async function main() {
    const DonationPool = await hre.ethers.getContractFactory("DontationPool");
    
}

main().catch((error) => {
    console.log(error);
    process.exitCode = 1;
})