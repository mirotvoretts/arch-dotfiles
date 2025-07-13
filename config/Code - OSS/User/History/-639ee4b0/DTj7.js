// Конфигурация
const TCT_TOKEN_ADDRESS = '0x...' // Замените на реальный адрес контракта TCT
const TCT_TOKEN_ABI = [
	'function balanceOf(address owner) view returns (uint256)',
	'function decimals() view returns (uint8)',
]

// Основная функция для получения баланса
async function getTCTBalance() {
	try {
		// Проверяем подключение MetaMask
		if (!window.ethereum) {
			console.log('MetaMask не установлен')
			return '0'
		}

		const provider = new ethers.BrowserProvider(window.ethereum)
		const signer = await provider.getSigner()
		const userAddress = await signer.getAddress()

		// Создаем контракт токена
		const tokenContract = new ethers.Contract(
			TCT_TOKEN_ADDRESS,
			TCT_TOKEN_ABI,
			provider
		)

		// Получаем баланс и decimals
		const [balance, decimals] = await Promise.all([
			tokenContract.balanceOf(userAddress),
			tokenContract.decimals(),
		])

		// Форматируем баланс
		return ethers.formatUnits(balance, decimals)
	} catch (error) {
		console.error('Ошибка при получении баланса TCT:', error)
		return '0'
	}
}

// Функция для обновления отображения баланса
async function updateTokenBalanceDisplay() {
	const balance = await getTCTBalance()
	const balanceElement = document.getElementById('tokenBalanceView')

	if (balanceElement) {
		balanceElement.textContent = `${parseFloat(balance).toFixed(2)} TCT`
	}
}

// Слушаем изменения аккаунта
window.ethereum.on('accountsChanged', () => {
	updateTokenBalanceDisplay()
})

// Инициализация при загрузке страницы
document.addEventListener('DOMContentLoaded', async () => {
	if (window.ethereum && window.ethereum.selectedAddress) {
		await updateTokenBalanceDisplay()
	}
})
