require("dotenv").config();

require("@nomiclabs/hardhat-truffle5");
require("solidity-coverage");

const gasReporterEnabled =
  process.env.REPORT_GAS && process.env.REPORT_GAS.toLowerCase() == 'true'

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.11",
  networks: {
		...(process.env.PRIVATE_KEY_AVAX_MAINNET && {
			avax_mainnet: {
				url: 'https://api.avax.network/ext/bc/C/rpc',
				gasPrice: 90000000000,
				chainId: 43114,
				accounts: [process.env.PRIVATE_KEY_AVAX_MAINNET]
			}
		}),
		
		...(process.env.PRIVATE_KEY_AVAX_TESTNET && {
			avax_testnet: {
				url: 'https://api.avax-test.network/ext/bc/C/rpc',
				gasPrice: 60000000000,
				chainId: 43113,
				accounts: [process.env.PRIVATE_KEY_AVAX_TESTNET]
			}
		})
	},
};
