require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: '0.8.28',
	paths: {
		sources: './contracts',
		tests: './test',
		cache: './cache',
		artifacts: './artifacts',
	},
	sepolia: {
		url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
		accounts: [process.env.PRIVATE_KEY],
	},
}
