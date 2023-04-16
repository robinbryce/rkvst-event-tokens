/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const dotenv = require("dotenv");
for (const env of ['.env', '.env.local'])
  dotenv.config({path: env});

require("@nomicfoundation/hardhat-chai-matchers");
require("hardhat-deploy");
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  // defaultNetwork: "polygon_mumbai",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
      chainId: 31337,
      gas: "auto",
      gasPrice: 0,
      initialBaseFeePerGas: 0,
    },
  },
  namedAccounts: {
    deployer: 10,
  },
  solidity: {
    version: "0.8.18",
    settings: {
      // hh does not support re-mappings yet
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 20,
        details: {
          yulDetails: {
            optimizerSteps: "u:",
          }
        }
      },
    },
  },
  paths: {
    // using hardhat-foundry to get hh to work with foundry & get the benefit
    // of source remappings. this means using sources here is redundant.
    // sources: "chaintrap",
    tests: "./test/hardhat",
    cache: ".local/hardhat/cache",
    artifacts: ".local/hardhat/artifacts",
  },
  mocha: {
    spec: ["test/hardhat/**/*.test.js"],
    watch: true,
    "watch-files": ["src/**/*.js", "test/hardhat/**/*.js"],
  },
};
