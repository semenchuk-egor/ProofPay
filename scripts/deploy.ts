import { ethers, upgrades } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  const [deployer] = await ethers.getSigners();
  const networkObj = await ethers.provider.getNetwork();
  const network = networkObj.name || "unknown";

  const ProofPay = await ethers.getContractFactory("ProofPay");
  const proxy = await upgrades.deployProxy(ProofPay, [deployer.address], {
    initializer: "initialize",
    kind: "uups"
  });
  await proxy.waitForDeployment();

  const proxyAddress = await proxy.getAddress();
  const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);

  const blockNumber = await ethers.provider.getBlockNumber();
  const block = await ethers.provider.getBlock(blockNumber);

  const deploymentsDir = path.join(process.cwd(), "deployments");
  if (!fs.existsSync(deploymentsDir)) fs.mkdirSync(deploymentsDir);
  const file = path.join(deploymentsDir, `${network}.json`);

  let current: any[] = [];
  if (fs.existsSync(file)) {
    try { current = JSON.parse(fs.readFileSync(file, "utf8")); } catch {}
  }

  current.push({
    network,
    proxy: proxyAddress,
    implementation: implAddress,
    deployer: deployer.address,
    txBlock: blockNumber,
    timestamp: Number(block?.timestamp || 0),
    commit: process.env.GITHUB_SHA || ""
  });

  fs.writeFileSync(file, JSON.stringify(current, null, 2));

  console.log("PROXY_ADDRESS=", proxyAddress);
  console.log("IMPLEMENTATION_ADDRESS=", implAddress);
  console.log(`Saved deployment to ${file}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
