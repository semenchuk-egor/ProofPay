import { ethers, upgrades, network } from "hardhat";
import fs from "fs";
import path from "path";

const ERC1967_IMPL_SLOT =
  "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc";

function deploymentsPath(net: string) {
  const dir = path.join(process.cwd(), "deployments");
  if (!fs.existsSync(dir)) fs.mkdirSync(dir);
  return path.join(dir, `${net}.json`);
}

async function getImplSafe(proxy: string): Promise<string | null> {
  try {
    return await upgrades.erc1967.getImplementationAddress(proxy);
  } catch {
    const raw = await ethers.provider.getStorage(proxy, ERC1967_IMPL_SLOT);
    const a = "0x" + raw.slice(26);
    return a.toLowerCase() === "0x0000000000000000000000000000000000000000" ? null : a;
  }
}

async function main() {
  const [deployer] = await ethers.getSigners();
  const netName = network.name; // "base_mainnet" или "base_sepolia"

  const Factory = await ethers.getContractFactory("ProofPay");
  const proxy = await upgrades.deployProxy(Factory, [deployer.address], {
    initializer: "initialize",
    kind: "uups"
  });
  await proxy.waitForDeployment();

  const proxyAddress = await proxy.getAddress();
  const implAddress = await getImplSafe(proxyAddress);
  const blockNumber = await ethers.provider.getBlockNumber();
  const block = await ethers.provider.getBlock(blockNumber);

  const file = deploymentsPath(netName);
  let arr: any[] = [];
  if (fs.existsSync(file)) {
    try { arr = JSON.parse(fs.readFileSync(file, "utf8")); } catch {}
  }
  arr.push({
    network: netName,
    proxy: proxyAddress,
    implementation: implAddress,
    deployer: deployer.address,
    txBlock: blockNumber,
    timestamp: Number(block?.timestamp || 0),
    commit: process.env.GITHUB_SHA || ""
  });
  fs.writeFileSync(file, JSON.stringify(arr, null, 2));

  console.log("PROXY_ADDRESS=", proxyAddress);
  console.log("IMPLEMENTATION_ADDRESS=", implAddress || "unavailable_yet");
  console.log(`Saved deployment to ${file}`);
}

main().catch((e) => { console.error(e); process.exit(1); });
