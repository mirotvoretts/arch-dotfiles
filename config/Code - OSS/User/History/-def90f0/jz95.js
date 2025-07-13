const hre = require('hardhat')

async function main() {
	const [owner, organization, donor] = await hre.ethers.getSigners()

	console.log('Owner address:', owner.address)
	console.log('Organization address:', organization.address)
	console.log('Donor address:', donor.address)

	const registry = await hre.ethers.getContractAt(
		'PlatformRegistry',
		'0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1'
	)

	const isVerified = await registry.verifiedOrganizations(organization.address)
	if (!isVerified) {
		console.log('ℹ️ Организация не верифицирована. Верифицируем...')
		const tx = await registry.connect(owner).verify(organization.address, true)
		await tx.wait()
		console.log(`✅ Организация ${organization.address} успешно верифицирована`)
	} else {
		console.log(`ℹ️ Организация ${organization.address} уже верифицирована`)
	}
}

main()
	.then(() => process.exit(0))
	.catch(error => {
		console.error('❌ Ошибка:', error)
		process.exit(1)
	})
