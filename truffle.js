const secret = require("./secret");
const HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  compilers: {
    solc: {
      version: "^0.5.2", // A version or constraint - Ex. "^0.5.0"
      settings: {
        optimizer: {
          enabled: true,
          runs: 500   // Optimize for how many times you intend to run the code
        }
      }
    }
  },
  migrations_directory: "./migrations",
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: 100, // Match any network id
      gasPrice: 5000000000,
      gas: 4500000,
    },
    ropsten: {
        provider: new HDWalletProvider(secret.mnemonic.ropsten, "https://ropsten.infura.io/v3/" + secret.infuraApiKey),
        network_id: 3,
        gasPrice: 3000000000,
        gas: 4500000
    },
    kovan: {
        provider: new HDWalletProvider(secret.mnemonic.kovan, "https://kovan.infura.io/v3/" + secret.infuraApiKey),
        network_id: 42,
        gasPrice: 3000000000,
        gas: 4500000
    },
    rinkeby: {
        provider: new HDWalletProvider(secret.mnemonic.rinkeby, "https://rinkeby.infura.io/v3/" + secret.infuraApiKey),
        network_id: 4,
        gasPrice: 3000000000,
        gas: 4500000
    },
    mainnet: {
        provider: new HDWalletProvider(secret.mnemonic.mainnet, "https://mainnet.infura.io/v3/" + secret.infuraApiKey),
        network_id: 1,
        gasPrice: 2000000000,
        gas: 6000000
    },
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 500
    }
  }
};
