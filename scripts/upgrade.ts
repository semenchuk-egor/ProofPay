import { ethers, upgrades, network } from "hardhat";
import fs from "fs";
import path from "path";

function deploymentsDir() {
  const dir = path.join(process.cwd(), "deployments");
  if (!fs.existsSync(dir)) fs.mkdirSync(dir);
  return dir;
}
function deploymentsPath(net: string) {
  return path.join(deploymentsDir(), `${net}.json`);
}
function metaPath(net: string) {
  return path.join(deploymentsDir(), `${net}.meta.json`);
}
function readJsonArray(file: string): any[] {
  if (!fs.existsSync(file)) return [];
  try { const v = JSON.parse(fs.readFileSync(file, "utf8")); return Array.isArray(v) ? v : []; } catch { return []; }
}
function readMetaProxy(net: string): string | null {
  const p = metaPath(net);
  if (!fs.existsSync(p)) return null;
  try { const m = JSON.parse(fs.readFileSync(p, "utf8")); return m.canonicalProxy || null; } catch { return null; }
}
function readLatestProxy(net: string): string | null {
  const arr = readJsonArray(deploymentsPath(net));
  if (!arr.length) return null;
  const last = arr[arr.length - 1];
  return last?.proxy || null;
}

async function main() {
  const netName = network.name;

  const fromMeta = readMetaProxy(netName);
  const fromFile = readLatestProxy(netName);
  const fromEnv = process.env.PROXY_ADDRESS || "";
  const PROXY_ADDRESS = fromMeta || fromFile || fromEnv;
  if (!PROXY_ADDRESS) throw new Error("No proxy address found (meta/deployments/env).");

  const Impl = await ethers.getContractFactory("ProofPay");
  const upgraded = await upgrades.upgradeProxy(PROXY_ADDRESS, Impl);
  await upgraded.waitForDeployment();

  const proxyAddress = await upgraded.getAddress();
  const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);

  const file = deploymentsPath(netName);
  const arr = readJsonArray(file);
  arr.push({
    network: netName,
    proxy: proxyAddress,
    implementation: implAddress,
    upgrade: true,
    timestamp: Math.floor(Date.now() / 1000),
    commit: process.env.GITHUB_SHA || ""
  });
  fs.writeFileSync(file, JSON.stringify(arr, null, 2));

  console.log("UPGRADED_PROXY_ADDRESS=", proxyAddress);
  console.log("NEW_IMPLEMENTATION_ADDRESS=", implAddress);
  console.log(`Updated ${file}`);
}

main().catch((e) => { console.error(e); process.exit(1); });
