require('dotenv').config();

const HDWalletProvider = require("@truffle/hdwallet-provider");
const privateKeys = process.env.PRIVATE_KEYS || "";
const infuraProjectId = process.env.INFURA_PROJECT_ID
const apiKeyScan = process.env.API_KEY

module.exports = {
  plugins: ['truffle-plugin-verify'],
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" //match any network id
    },
    testnet: {
      networkCheckTimeout: 10000000,
      provider: function() {
        return new HDWalletProvider(
          privateKeys.split(','), // array of private keys
          `https://matic-mumbai.chainstacklabs.com:8545/` // Url to an Polygon node
          )
      },
      network_id: 80001,
      // confirmations: 10,
      // timeoutBlocks: 200,
      skipDryRun: true
      // gas: 200000,
      // gasPrice: 20000000
    },
    neon: {
      provider: function() {
        return new HDWalletProvider(
          privateKeys.split(','), // array of private keys
          `https://proxy.devnet.neonlabs.org/solana` // Url to neon labs
          )
      },
      from: "0x9b17C9E2AA27F93b1d0e71b872069e096cB41233",
      network_id: "*"
    },
    mumbai: {
      networkCheckTimeout: 30000000000,
      provider: function() {
        return new HDWalletProvider(
          privateKeys.split(','), // array of private keys
          `https://polygon-mumbai.g.alchemy.com/v2/JO_wt26E5SJ7rno8PUeWXYetPYQyYU03` // Url to an Polygon node
          )
      },
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    celo: {
      provider: function() {
        return new HDWalletProvider(
          privateKeys.split(','), // array of private keys
          `https://alfajores-forno.celo-testnet.org` // Url to an Polygon node
          )
      },
      network_id: 44787,
      gas: 4000000
    },
    gnosis: {
      provider: function() {
        return new HDWalletProvider(
          privateKeys.split(','), // array of private keys
          'https://optimism.gnosischain.com'
          )
      },
      network_id: 300,
      timeoutBlocks: 200,
      skipDryRun: true
      //gasPrice: 1500000000
    },
    cronos: {
      provider: function() {
        return new HDWalletProvider(
          privateKeys.split(','), // array of private keys
          `wss://cronos-testnet-3.crypto.org:8546` // URL to cronos RPC
          )
      },
      network_id: "*",
      skipDryRun: true
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(
          privateKeys.split(','), // array of private keys
          `https://rinkeby.infura.io/v3/`+infuraProjectId // URL to infura rpc
          )
      },
      network_id: 4
    },
    bnb: {
      provider: function() {
        return new HDWalletProvider(
          privateKeys.split(','), // array of private keys
          `https://data-seed-prebsc-1-s1.binance.org:8545/` // Url to Bnb node
          )
      },
      network_id: 97,
    }
  },
  // Configure your compilers
  compilers: {
    solc: {
      optimizer: {
        enabled: false,
        runs: 200
      },
      version: "0.8.9" 
    }
  },
  api_keys: {
    // etherscan: "2IWVY2824WC7VZ56UXH49FSPK5PPPZC7IG" // mumbai
    bscscan: "Y8NSD2PV8IYBAER6A46J61UPMFMDP3TGKR"// bnb 
    // etherscan: "AJ45C6F74SJ2P3EMW61V3DD1CJAJC3HTJK" // ethereum
    // etherscan: "PMPIGW8S5JCZU92W8IADFPI1BNMEP5UBFT" // Rinkeby
    // etherscan: "4UGX9RKT7G9GVBBMFW5ZMQNJMGECAXVII4" // Celo
  }
};