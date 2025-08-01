const hre = require('hardhat')

async function main() {
	const [owner, organization, donor] = await hre.ethers.getSigners()

	console.log('Owner address:', owner.address)
	console.log('Organization address:', organization.address)
	console.log('Donor address:', donor.address)

	const registry = await hre.ethers.getContractAt(
		'PlatformRegistry',
		'0x5FC8d32690cc91D4c39d9d3abcBD16989F875707'
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

	// Подключаемся к CharityCampaign от имени донора
	const campaign = await hre.ethers.getContractAt(
		'CharityCampaign',
		campaignAddress,
		donor // ← передаем донора как signer
	)

	const donationAmount = '1000000'

	console.log(`💸 Донор ${donor.address} делает пожертвование...`)

	const donorBalance = await hre.ethers.provider.getBalance(donor.address)
	console.log(`Баланс донора: ${hre.ethers.formatEther(donorBalance)} ETH`)

	const txDonate = await campaign.donate({
		value: hre.ethers.parseEther(donationAmount),
	})

	await txDonate.wait()

	console.log(
		`✅ Пожертвование на сумму ${donationAmount} ETH успешно отправлено!`
	)
}

main()
	.then(() => process.exit(0))
	.catch(error => {
		console.error('❌ Ошибка:', error)
		process.exit(1)
	})
