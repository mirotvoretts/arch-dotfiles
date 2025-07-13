const hre = require('hardhat')

async function main() {
	const Token = await hre.ethers.getContractFactory('PlatformToken')
	const token = await Token.deploy(process.env.ADMIN_ADDRESS)
	await token.waitForDeployment()
	console.log(`Token deployed to: ${token.target}`)

	const Registry = await hre.ethers.getContractFactory('PlatformRegistry')
	const registry = await Registry.deploy(
		process.env.ADMIN_ADDRESS,
		5,
		token.target
	)
	await registry.waitForDeployment()
	console.log(`Registry deployed to: ${registry.target}`)

	await token.grantRole(await token.MINTER_ROLE(), registry.target)
	console.log('Granted MINTER_ROLE to Registry')
}

main().catch(error => {
	console.error(error)
	process.exitCode = 1
})
