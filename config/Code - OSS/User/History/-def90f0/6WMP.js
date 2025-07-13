const hre = require('hardhat')

async function main() {
	const [owner, organization] = await hre.ethers.getSigners()

	console.log('Owner address:', owner.address)
	console.log('Organization address:', organization.address)

	const registry = await hre.ethers.getContractAt(
		'PlatformRegistry',
		'0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1'
	)

	const isVerified = await registry.verifiedOrganizations(organization.address)
	if (!isVerified) {
		console.log('ℹ️ Организация не верифицирована. Верифицируем...')
		const txVerify = await registry
			.connect(owner)
			.verifyOrganization(organization.address, true)
		await txVerify.wait()
		console.log(`✅ Организация ${organization.address} успешно верифицирована`)
	} else {
		console.log(`ℹ️ Организация ${organization.address} уже верифицирована`)
	}

	const goalInETH = '0.5'
	const durationInSeconds = 86400

	console.log('🚀 Создаём новую кампанию...')

	const txCreate = await registry
		.connect(organization)
		.createCampaign(hre.ethers.parseEther(goalInETH), durationInSeconds)

	const receipt = await txCreate.wait()

	const event = receipt.logs.find(
		log =>
			log.topics[0] ===
			hre.ethers.id('CampaignCreated(uint256,address,address)')
	)

	if (!event) {
		throw new Error('❌ Не найдено событие CampaignCreated')
	}

	const campaignCreatedEvent = registry.interface.parseLog(event)
	const campaignAddress = campaignCreatedEvent.args.campaignAddress

	console.log('✅ Кампания успешно создана!')
	console.log('ID кампании:', campaignCreatedEvent.args.campaignId.toString())
	console.log('Адрес кампании:', campaignAddress)
}

main()
	.then(() => process.exit(0))
	.catch(error => {
		console.error('❌ Ошибка:', error)
		process.exit(1)
	})
