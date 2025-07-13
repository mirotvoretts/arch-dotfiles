const connectButton = document.getElementById('connectButton')
const accountAddress = document.getElementById('accountAddress')

connectButton.addEventListener('click', async () => {
	// 1. Очистка localStorage
	localStorage.removeItem('walletAddress')
	localStorage.removeItem('isConnected')

	// 2. Сброс состояния в приложении
	setCurrentAccount(null)
	setIsConnected(false)

	// 3. (Опционально) Отписка от событий
	if (window.ethereum?.removeListener) {
		window.ethereum.removeListener('accountsChanged', handleAccountsChanged)
	}

	if (typeof window.ethereum !== 'undefined') {
		try {
			const accounts = await window.ethereum.request({
				method: 'eth_requestAccounts',
			})
			const account = accounts[0]
			accountAddress.textContent = `Подключен аккаунт: ${account}`
		} catch (error) {
			console.error('Ошибка при подключении к MetaMask:', error)
			alert('Ошибка при подключении к MetaMask.')
		}
	} else {
		alert('MetaMask не установлен. Пожалуйста, установите расширение MetaMask.')
	}
})
