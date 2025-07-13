const connectButton = document.getElementById('connectButton')
const disconnectButton = document.getElementById('disconnectButton')
const accountAddress = document.getElementById('accountAddress')

let currentAccount = null
connectButton.addEventListener('click', async () => {
	if (typeof window.ethereum !== 'undefined') {
		try {
			if (currentAccount) {
				accountAddress.textContent = ''
				currentAccount = null
				connectButton.style.display = 'inline-block'
				disconnectButton.style.display = 'none'
				alert('Вы успешно отключились от MetaMask.')
			}

			const accounts = await window.ethereum.request({
				method: 'eth_requestAccounts',
			})
			currentAccount = accounts[0]
			accountAddress.textContent = `Подключен аккаунт: ${currentAccount}`
			connectButton.style.display = 'none'
			disconnectButton.style.display = 'inline-block'
		} catch (error) {
			console.error('Ошибка при подключении к MetaMask:', error)
			alert('Ошибка при подключении к MetaMask.')
		}
	} else {
		alert('MetaMask не установлен. Пожалуйста, установите расширение MetaMask.')
	}
})

disconnectButton.addEventListener('click', () => {
	if (currentAccount) {
		accountAddress.textContent = ''
		currentAccount = null
		connectButton.style.display = 'inline-block'
		disconnectButton.style.display = 'none'
		alert('Вы успешно отключились от MetaMask.')
	}
})
