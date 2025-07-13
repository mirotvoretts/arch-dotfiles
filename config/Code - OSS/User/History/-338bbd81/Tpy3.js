const hre = require('hardhat')

async function main() {
	const PlatformRegistry = await hre.ethers.getContractFactory(
		'PlatformRegistry'
	)
	const contract = await PlatformRegistry.deploy(
		'0x5eBdD0632E083Bb59a1c642FC2D3634d43c27dB4',
		5
	)

	await contract.waitForDeployment()
	console.log('Contract deployed to:', await contract.getAddress())
}

main().catch(error => {
	console.log(error)
	process.exitCode = 1
})
