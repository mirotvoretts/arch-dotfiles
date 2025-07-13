const { ethers } = require('ethers')

const abi = [
	'function verifyOrganization(address _organizationAddress, bool _isVerified) public onlyOwner',
	'function createCampaign(uint96 _goal, uint64 _durationInSeconds) external onlyVerified returns (address)',
	'event CampaignCreated(uint indexed campaignId, address indexed campaignAddress, address indexed creator)',
]

// Адрес твоего контракта PlatformRegistry
const registryAddress = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512' // Замени на реальный адрес

// Адрес организации, которую ты хочешь верифицировать
const organizationAddress = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266' // Замени на реальный адрес

// Настройки кампании
const goalInETH = '0.5' // Целевая сумма в ETH
const durationInSeconds = 86400 // 1 день

async function main() {
	if (typeof window.ethereum !== 'undefined') {
		const provider = new ethers.BrowserProvider(window.ethereum)
		const signer = await provider.getSigner()

		const registryContract = new ethers.Contract(registryAddress, abi, signer)

		console.log('Подключаюсь к контракту...')

		try {
			console.log(`Верифицируем организацию: ${organizationAddress}`)
			const txVerify = await registryContract.verifyOrganization(
				organizationAddress,
				true
			)
			await txVerify.wait()
			console.log('Организация успешно верифицирована.')
		} catch (err) {
			console.error('Ошибка при верификации:', err.message)
		}

		try {
			console.log('Создаём кампанию...')
			const txCreate = await registryContract.createCampaign(
				ethers.parseEther(goalInETH),
				durationInSeconds
			)

			// Ждём подтверждения транзакции
			const receipt = await txCreate.wait()

			// Парсим событие CampaignCreated из логов
			const event = receipt.logs.find(log =>
				log.topics.includes(
					ethers.id('CampaignCreated(uint256,address,address)')
				)
			)

			if (!event) {
				throw new Error('Не найдено событие CampaignCreated')
			}

			const campaignCreatedEvent = registryContract.interface.parseLog(event)
			const campaignAddress = campaignCreatedEvent.args.campaignAddress

			console.log('✅ Кампания успешно создана!')
			console.log(
				'ID кампании:',
				campaignCreatedEvent.args.campaignId.toString()
			)
			console.log('Адрес кампании:', campaignAddress)
		} catch (err) {
			console.error('Ошибка при создании кампании:', err.message)
		}
	} else {
		alert('MetaMask не установлен. Пожалуйста, установите его.')
	}
}

if (typeof module === 'object' && typeof module.exports === 'object') {
	module.exports = main
} else {
	window.main = main
}
