// hardhat.config.js
require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');
const { mnemonic } = require('./secrets.json');
require("hardhat-abi-exporter");
require("hardhat-gas-reporter");


/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {


  mocha: {
      reporter: 'eth-gas-reporter',
      reporterOptions : {
          
      }
    },
  
  abiExporter: {
    path: './abi/pretty',
    pretty : false
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    testnet :{
      url:"https://api.s0.b.hmny.io",
      accounts: {mnemonic : mnemonic},
      chainId:1666700000,
    },
    mainnet : {
      url:"https://api.harmony.one",
      accounts: {mnemonic : mnemonic},
      chainId:1666600000,
    }
  },
  solidity: {
    compilers: [
        {
          version: "0.5.7"
        },
        {
          version: "0.8.3"
        },
        {
          version: "0.6.12"
        }
      ]
    },
    mocha:{
      timeout:1000000
    }
  };

