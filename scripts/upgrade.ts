import { ethers, upgrades } from "hardhat";
import fs from "fs";
import path from "path";

function readLatestProxy(network: string): string | null {
  const file = path.join(process.cwd(), "deployments", `${network}.json`);
  if (!fs.existsSync(file)) return null;
  try {
    const arr = JSON.parse(fs.readFileSync(file, "utf8"));
    if (Array.isArray(arr) && arr.length > 0) return arr[arr.length - 1].proxy || null;
  } catch {}
  return null;
}

async function main() {
  const networkObj = await ethers.provider.getNetwork();
  const network = networkObj.name || "unknown";
  const fromFile = readLatestProxy(network);
  const PROXY_ADDRESS = process.env.PROXY_ADDRESS || fromFile || "";
  if (!PROXY_ADDRESS) throw new Error("Missing PROXY_ADDRESS and no deployments file found.");

  const ProofPayV = await ethers.getContractFactory("ProofPay");
  const upgraded = await upgrades.upgradeProxy(PROXY_ADDRESS, ProofPayV);
  await upgraded.waitForDeployment();

  const proxyAddress = await upgraded.getAddress();
  const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);

  const file = path.join(process.cwd(), "deployments", `${network}.json`);
  let current: any[] = [];
  if (fs.existsSync(file)) {
    try { current = JSON.parse(fs.readFileSync(file, "utf8")); } catch {}
  }
  current.push({
    network,
    proxy: proxyAddress,
    implementation: implAddress,
    upgrade: true,
    timestamp: Math.floor(Date.now() / 1000),
    commit: process.env.GITHUB_SHA || ""
  });
  fs.writeFileSync(file, JSON.stringify(current, null, 2));

  console.log("UPGRADED_PROXY_ADDRESS=", proxyAddress);
  console.log("NEW_IMPLEMENTATION_ADDRESS=", implAddress);
  console.log(`Updated ${file}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
