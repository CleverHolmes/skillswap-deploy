require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  paths: {
    artifacts: "../src/artifacts",
  },
  solidity: "0.8.17",
  etherscan: {
    apiKey: {
      goerli: 'PD6SWDBT9XTRY81QW9E7VYN721KGBX3ZD5'
    }
  },
  networks: {
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/HMem6t-3h4eeV-4eP5F6MCnKwIZqAEjH",
      accounts: [
        `249a384e7e19276680f54031177e39e4dc6584636e733a2847e2ff56b0701259`,
      ],
    },
  },
};


//0xc15FBa4f209Fa9edf0c39dEf16a1644c9372C59E
//Goerli Key:
	//7GrB6EItQJvBze51yHWBx0mHpM8jEY0w