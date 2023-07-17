const hre = require("hardhat");

async function main() {
  
  const medBlock = await hre.ethers.getContractFactory("MedBlock");
  const MedBlock = await medBlock.deploy();

  await MedBlock.deployed();

  console.log(
    `Contract Address:  ${MedBlock.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


// const hre = require("hardhat");


// async function main() {
//   const MedBlock = await hre.ethers.deployContract("MedBlock"); //fetching bytecode and ABI
  
//   await MedBlock.waitForDeployment();//deploying your smart contract

//   console.log("Deployed contract address:",`${MedBlock.target}`);
// }

// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });