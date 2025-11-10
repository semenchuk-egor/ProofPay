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
  const net = await ethers.provider.getNetwork();
  const chainId = Number(net.chainId);
  const file = fileFor(chainId);
  const entries = readJson(file);
  if (!entries.length) {
    console.log("no deployments history");
    return;
  }
  const last = entries[entries.length - 1];
  const proxy = last.proxy;
  if (!proxy || !/^0x[0-9a-fA-F]{40}$/.test(proxy)) {
    console.log("invalid proxy in deployments");
    return;
  }

  const impl = await upgrades.erc1967.getImplementationAddress(proxy);
  if (!impl || !/^0x[0-9a-fA-F]{40}$/.test(impl)) {
    console.log("cannot resolve implementation");
    return;
  }

  const block = await ethers.provider.getBlock("latest");
  const entry: Entry = {
    network: network.name,
    chainId,
    proxy,
    implementation: impl,
    deployer: await signer.getAddress(),
    txBlock: block?.number || null,
    timestamp: Number(block?.timestamp || 0),
    commit: process.env.GITHUB_SHA || ""
  };

  const next = [...entries, entry];
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, JSON.stringify(next, null, 2));
  console.log("backfilled implementation:", impl);
}

main().catch((e) => { console.error(e); process.exit(1); });
