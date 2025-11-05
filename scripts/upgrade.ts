import { ethers, upgrades } from "hardhat";

// Set your deployed proxy address here before running the upgrade command
const PROXY_ADDRESS = process.env.PROXY_ADDRESS || "";

async function main() {
  if (!PROXY_ADDRESS) {
    throw new Error("Missing PROXY_ADDRESS env var");
  }
  const ProofPayV = await ethers.getContractFactory("ProofPay");
  const upgraded = await upgrades.upgradeProxy(PROXY_ADDRESS, ProofPayV);
  await upgraded.waitForDeployment();

  const proxyAddress = await upgraded.getAddress();
  const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);

  console.log("UPGRADED_PROXY_ADDRESS=", proxyAddress);
  console.log("NEW_IMPLEMENTATION_ADDRESS=", implAddress);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
