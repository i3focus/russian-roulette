const hre = require("hardhat");

const CONTRACT = "RussianRoulette";

async function main() {
  const RussianRoulette = await hre.ethers.deployContract(CONTRACT);

  await RussianRoulette.waitForDeployment();

  console.table(RussianRoulette);
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
