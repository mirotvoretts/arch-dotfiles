// Конфигурация токена TCT (добавьте в начало файла)
const TCT_TOKEN_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3' // Замените на реальный адрес контракта
const TCT_TOKEN_ABI = [
	'function balanceOf(address owner) view returns (uint256)',
	'function decimals() view returns (uint8)',
]

// Функция для получения баланса TCT (добавьте новую функцию)
async function getTCTBalance(userAddress) {
	try {
		const provider = new ethers.BrowserProvider(window.ethereum)
		const tokenContract = new ethers.Contract(
			TCT_TOKEN_ADDRESS,
			TCT_TOKEN_ABI,
			provider
		)

		const [balance, decimals] = await Promise.all([
			tokenContract.balanceOf(userAddress),
			tokenContract.decimals(),
		])

		return {
			raw: balance,
			formatted: parseFloat(ethers.formatUnits(balance, decimals)).toFixed(2),
		}
	} catch (error) {
		console.error('Ошибка при получении баланса TCT:', error)
		return {
			raw: 0,
			formatted: '0.00',
		}
	}
}

// Модифицируем существующий обработчик подключения
connectButton.addEventListener('click', async () => {
	if (typeof window.ethereum !== 'undefined') {
		try {
			const accounts = await window.ethereum.request({
				method: 'eth_requestAccounts',
			})
			const account = accounts[0]

			// Обновляем отображение адреса (существующий код)
			accountAddress.textContent = `Подключен аккаунт: ${account}`

			// Добавляем отображение баланса TCT
			const balance = await getTCTBalance(account)
			const balanceElement = document.createElement('div')
			balanceElement.id = 'tctBalance'
			balanceElement.innerHTML = `
        <div style="margin-top: 10px;">
          <strong>Баланс TCT:</strong> ${balance.formatted} TCT
        </div>
      `
			accountAddress.appendChild(balanceElement)

			// Добавляем обновление баланса при изменениях
			const tokenContract = new ethers.Contract(
				TCT_TOKEN_ADDRESS,
				TCT_TOKEN_ABI,
				new ethers.BrowserProvider(window.ethereum)
			)

			tokenContract.on('Transfer', (from, to) => {
				if (from === account || to === account) {
					updateTCTBalance(account)
				}
			})
		} catch (error) {
			console.error('Ошибка при подключении к MetaMask:', error)
			alert('Ошибка при подключении к MetaMask.')
		}
	} else {
		alert('MetaMask не установлен. Пожалуйста, установите расширение MetaMask.')
	}
})

// Функция для обновления баланса (добавьте новую функцию)
async function updateTCTBalance(userAddress) {
	const balance = await getTCTBalance(userAddress)
	const balanceElement = document.getElementById('tctBalance')
	if (balanceElement) {
		balanceElement.innerHTML = `
      <div style="margin-top: 10px;">
        <strong>Баланс TCT:</strong> ${balance.formatted} TCT
      </div>
    `
	}
}

// Проверка подключенного кошелька при загрузке страницы (добавьте новый код)
window.addEventListener('load', async () => {
	if (typeof window.ethereum !== 'undefined') {
		const accounts = await window.ethereum.request({ method: 'eth_accounts' })
		if (accounts.length > 0) {
			const account = accounts[0]
			accountAddress.textContent = `Подключен аккаунт: ${account}, баланс TCT: ${getTCTBalance(
				account
			)}`

			const balance = await getTCTBalance(account)
			const balanceElement = document.createElement('div')
			balanceElement.id = 'tctBalance'
			balanceElement.innerHTML = `
        <div style="margin-top: 10px;">
          <strong>Баланс TCT:</strong> ${balance.formatted} TCT
        </div>
      `
			accountAddress.appendChild(balanceElement)
		}
	}
})
