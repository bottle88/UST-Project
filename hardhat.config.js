require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.11",
  networks: {
    hardhat: {
      chainId: 1337, // Replace with the desired chain ID
    },
    localhost: {
      url: "http://localhost:8545", // Update with the correct URL for your local Hardhat node
    },
  },
};





// /**
//  * @type import('hardhat/config').HardhatUserConfig
//  */

// require('dotenv').config();
// require("@nomiclabs/hardhat-ethers");

// const { API_URL, PRIVATE_KEY } = process.env;

// module.exports = {
//    solidity: "0.8.11",
//    defaultNetwork: "volta",
//    networks: {
//       hardhat: {},
//       volta: {
//          url: API_URL,
//          accounts: [`0x${PRIVATE_KEY}`],
//          gas: 8000000, // Adjust the gas limit value as needed
//          gasPrice: 800000000000,
//       }
//    },
// }
