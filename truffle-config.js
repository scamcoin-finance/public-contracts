const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');

const Web3 = require("web3");
const web3 = new Web3();

const mnemonic = fs.readFileSync(".secret").toString().trim();
const mnemonic_main = fs.readFileSync(".secret_main").toString().trim();

module.exports = {
  /**
  * $ truffle migrate --network <network-name>
  */
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      from: "0x804484C1dD7F962661603fA4Eb7892AA3273793e",
      network_id: "5777" // Match any network id
    },
    testnet: {
      provider: () => new HDWalletProvider(mnemonic, `https://data-seed-prebsc-1-s1.binance.org:8545`),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    // bsc: {
    //   provider: () => new HDWalletProvider(mnemonic_main, `https://bsc-dataseed1.binance.org`),
    //   network_id: 56,
    //   confirmations: 5,
    //   timeoutBlocks: 200,
    //   gasPrice: web3.utils.toWei('8', 'gwei'),
    //   skipDryRun: true
    // },
  },
  compilers: {
    solc: {
      version: ">=0.6.0 <0.8.2",
    }
  }
};
