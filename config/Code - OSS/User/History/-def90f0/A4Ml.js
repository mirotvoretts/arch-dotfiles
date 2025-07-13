const hre = require('hardhat')

async function main() {
	const contract = await hre.ethers.getContractAt(
		'SimpleStorage',
		'0x...адрес...'
	)
	await contract.setNumber(100)
	console.log('Number:', (await contract.number()).toString())
}

main()
