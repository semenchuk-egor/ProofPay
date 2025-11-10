import { ethers, upgrades, network } from "hardhat";
import fs from "fs";
import path from "path";

type Entry = {
  network: string;
  chainId: number;
  proxy: string;
  implementation: string | null;
  deployer: string;
  txBlock: number | null;
  timestamp: number;
  commit: string;
};

function fileFor(chainId: number) {
  return path.join(process.cwd(), "deployments", `${chainId}.json`);
}

function readJson(file: string): Entry[] {
  if (!fs.existsSync(file)) return [];
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

async function main() {
  const [signer] = await ethers.getSigners();
  const chainId = Number((await ethers.provider.getNetwork()).chainId);
  const file = fileFor(chainId);
  const entries = readJson(file);
  if (!entries.length) throw new Error("No deployments history");
  const proxy = entries[entries.length - 1].proxy;

  const ProofPay = await ethers.getContractFactory("ProofPay");
  const upgraded = await upgrades.upgradeProxy(proxy, ProofPay);
  await upgraded.waitForDeployment();

  const implAddress = await upgrades.erc1967.getImplementationAddress(proxy);
  const block = await ethers.provider.getBlock("latest");

  const entry: Entry = {
    network: network.name,
    chainId,
    proxy,
    implementation: implAddress,
    deployer: await signer.getAddress(),
    txBlock: block?.number || null,
    timestamp: Number(block?.timestamp || 0),
    commit: process.env.GITHUB_SHA || ""
  };

  const next = [...entries, entry];
  fs.writeFileSync(file, JSON.stringify(next, null, 2));

  console.log("UPGRADED_PROXY=", proxy);
  console.log("NEW_IMPLEMENTATION=", implAddress);
  console.log("Saved deployment to", file);
}

main().catch((e) => { console.error(e); process.exit(1); });
