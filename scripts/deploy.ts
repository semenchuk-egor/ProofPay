import { ethers, upgrades, network } from "hardhat";
import fs from "fs";
import path from "path";

const ERC1967_IMPL_SLOT = "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc";

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
function readMeta(net: string): any | null {
  const p = metaPath(net);
  if (!fs.existsSync(p)) return null;
  try { return JSON.parse(fs.readFileSync(p, "utf8")); } catch { return null; }
}
async function getImplSafe(addr: string): Promise<string | null> {
  try { return await upgrades.erc1967.getImplementationAddress(addr); }
  catch {
    const raw = await ethers.provider.getStorage(addr, ERC1967_IMPL_SLOT);
    const a = "0x" + raw.slice(26);
    return /^0x0{40}$/i.test(a.slice(2)) ? null : ethers.getAddress(a);
  }
}

async function main() {
  const netName = network.name;
  deploymentsDir();

  const force = process.env.FORCE_DEPLOY === "1";
  const meta = readMeta(netName);
  if (meta?.canonicalProxy && !force) {
    const proxy = meta.canonicalProxy;
    const impl = await getImplSafe(proxy);
    console.log("PROXY_ADDRESS=", proxy);
    console.log("IMPLEMENTATION_ADDRESS=", impl || "unavailable_yet");
    console.log(`Using canonical proxy from ${metaPath(netName)}`);
    return;
  }

  const file = deploymentsPath(netName);
  const arr = readJsonArray(file);
  const last = arr.length ? arr[arr.length - 1] : null;
  if (last?.proxy && !force) {
    const impl = last.implementation || (await getImplSafe(last.proxy));
    console.log("PROXY_ADDRESS=", last.proxy);
    console.log("IMPLEMENTATION_ADDRESS=", impl || "unavailable_yet");
    console.log(`Using existing proxy from ${file}`);
    return;
  }

  const [deployer] = await ethers.getSigners();
  const Factory = await ethers.getContractFactory("ProofPay");
  const proxy = await upgrades.deployProxy(Factory, [deployer.address], { initializer: "initialize", kind: "uups" });
  await proxy.waitForDeployment();

  const proxyAddress = await proxy.getAddress();
  const implAddress = await getImplSafe(proxyAddress);
  const blockNumber = await ethers.provider.getBlockNumber();
  const block = await ethers.provider.getBlock(blockNumber);

  const next = readJsonArray(file);
  next.push({
    network: netName,
    proxy: proxyAddress,
    implementation: implAddress || null,
    deployer: (await ethers.getSigners())[0].address,
    txBlock: blockNumber,
    timestamp: Number(block?.timestamp || 0),
    commit: process.env.GITHUB_SHA || ""
  });
  fs.writeFileSync(file, JSON.stringify(next, null, 2));

  console.log("PROXY_ADDRESS=", proxyAddress);
  console.log("IMPLEMENTATION_ADDRESS=", implAddress || "unavailable_yet");
  console.log(`Saved deployment to ${file}`);
}

main().catch((e) => { console.error(e); process.exit(1); });
