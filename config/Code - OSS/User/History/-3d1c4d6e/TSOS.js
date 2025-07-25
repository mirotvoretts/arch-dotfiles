require('@nomicfoundation/hardhat-toolbox')
require('dotenv').config()

module.exports = {
	solidity: '0.8.28',
	networks: {
		hardhat: {
			url: 'http://127.0.0.1:8545',
			chainId: 31337,
		},
	},

	paths: {
		sources: './contracts',
		artifacts: './artifacts',
	},
}
