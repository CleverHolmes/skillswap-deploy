const hre = require("hardhat");

async function main() {
  const SkillSwap = await hre.ethers.getContractFactory("SkillSwap");
  const skillSwap = await SkillSwap.deploy();

  await skillSwap.deployed();

  console.log(`SkillSwap is deployed to ${skillSwap.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
