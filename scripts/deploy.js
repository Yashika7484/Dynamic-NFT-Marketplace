const hre = require("hardhat");

async function main() {
  console.log("Deploying DynamicNFTMarketplace contract...");

  // Get the contract Factory
  const DynamicNFTMarketplace = await hre.ethers.getContractFactory("DynamicNFTMarketplace");
  
  // Deploy the contract
  const marketplace = await DynamicNFTMarketplace.deploy();

  // Wait for deployment to finish
  await marketplace.waitForDeployment();
  
  const address = await marketplace.getAddress();
  console.log(`DynamicNFTMarketplace deployed to: ${address}`);
  
  console.log("Deployment completed successfully!");
  
  // For networks that support verification, you can uncomment this to verify the contract
  // console.log("Waiting for block confirmations...");
  // await marketplace.deployTransaction.wait(6);
  // console.log("Verifying contract...");
  // await hre.run("verify:verify", {
  //   address: marketplace.address,
  //   constructorArguments: [],
  // });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

