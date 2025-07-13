const Web3 = require('web3')
const PlatformRegistryABI = require('../artifacts/contracts/PlatformRegistry.sol/PlatformRegistry.json')
const CharityCampaignABI = require('../artifacts/contracts/CharityCampaign.sol/CharityCampaign.json')

async function main() {
	// Инициализация Web3
	const web3 = new Web3('http://localhost:8545') // или ваш RPC URL

	// Получаем аккаунты
	const accounts = await web3.eth.getAccounts()
	const owner = accounts[0]
	const organization = accounts[1]
	const donor = accounts[2]

	console.log('Owner address:', owner)
	console.log('Organization address:', organization)
	console.log('Donor address:', donor)

	// Адрес контракта PlatformRegistry
	const registryAddress = '0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1'

	// Создаем экземпляр контракта
	const registry = new web3.eth.Contract(PlatformRegistryABI, registryAddress)

	// 1. Проверяем верификацию организации
	const isVerified = await registry.methods
		.verifiedOrganizations(organization)
		.call()
	if (!isVerified) {
		console.log('ℹ️ Организация не верифицирована. Верифицируем...')
		const tx = await registry.methods
			.verify(organization, true)
			.send({ from: owner })
		console.log(
			`✅ Организация ${organization} успешно верифицирована, tx: ${tx.transactionHash}`
		)
	} else {
		console.log(`ℹ️ Организация ${organization} уже верифицирована`)
	}

	// 2. Создаём новую кампанию
	console.log('\n⏳ Создаем новую кампанию...')
	const goal = '50000000'
	const deadline = Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60 // 30 дней

	// Получаем текущее количество кампаний организации
	const initialCampaigns = await registry.methods
		.getOrganizationCampaigns(organization)
		.call()
	const initialCount = initialCampaigns.length

	// Создаем кампанию
	const tx = await registry.methods
		.createCampaign(goal, deadline)
		.send({ from: organization })
	console.log(`✅ Транзакция создания кампании: ${tx.transactionHash}`)

	// Получаем адрес созданной кампании
	const updatedCampaigns = await registry.methods
		.getOrganizationCampaigns(organization)
		.call()
	const newCampaignAddress = updatedCampaigns[updatedCampaigns.length - 1]

	console.log(`📌 Адрес созданной кампании: ${newCampaignAddress}`)

	// 3. Подключаемся к CharityCampaign
	const campaign = new web3.eth.Contract(CharityCampaignABI, newCampaignAddress)

	// 4. Делаем пожертвование от донора
	console.log('\n💸 Делаем пожертвование от донора...')
	const donationAmount = web3.utils.toWei('1', 'ether')
	const donateTx = await campaign.methods.donate().send({
		from: donor,
		value: donationAmount,
	})
	console.log(
		`✅ Донор ${donor} пожертвовал 1 ETH, tx: ${donateTx.transactionHash}`
	)

	// 5. Проверяем статус кампании
	console.log('\n📊 Проверяем статус кампании...')
	const status = await campaign.methods.getStatus().call()
	console.log(`📌 Статус кампании: ${status}`)
}

main()
	.then(() => process.exit(0))
	.catch(error => {
		console.error('❌ Ошибка:', error)
		process.exit(1)
	})
