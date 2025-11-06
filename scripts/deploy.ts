import { ethers, upgrades, network as hre } from "hardhat";
import fs from "fs";
import path from "path";

const ERC1967_IMPL_SLOT =
  "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc";

async function getImplSafe(proxyAddress: string): Promise<string> {
  try {
    return await upgrades.erc1967.getImplementationAddress(proxyAddress);
  } catch {
    const raw = await ethers.provider.getStorage(proxyAddress, ERC1967_IMPL_SLOT);
    const addr = "0x" + raw.slice(26);
    if (addr.toLowerCase() !== "0x0000000000000000000000000000000000000000") {
      return ethers.getAddress(addr);
    }
    return "";
  }
}

function deploymentsPath(net: string) {
  const dir = path.join(process.cwd(), "deployments");
  if (!fs.existsSync(dir)) fs.mkdirSync(dir);
  return path.join(dir, `${net}.json`);
}

async function main() {
  const [deployer] = await ethers.getSigners();
  const networkName = hre.name || hre.network.name || "unknown";

  const Factory = await ethers.getContractFactory("ProofPay");
  const proxy = await upgrades.deployProxy(Factory, [deployer.address], {
    initializer: "initialize",
    kind: "uups"
  });
  await proxy.waitForDeployment();

  const proxyAddress = await proxy.getAddress();
  let implAddress = await getImplSafe(proxyAddress);

  const blockNumber = await ethers.provider.getBlockNumber();
  const block = await ethers.provider.getBlock(blockNumber);

  const file = deploymentsPath(networkName);
  let current: any[] = [];
  if (fs.existsSync(file)) {
    try { current = JSON.parse(fs.readFileSync(file, "utf8")); } catch {}
  }

  current.push({
    network: networkName,
    proxy: proxyAddress,
    implementation: implAddress || null,
    deployer: deployer.address,
    txBlock: blockNumber,
    timestamp: Number(block?.timestamp || 0),
    commit: process.env.GITHUB_SHA || ""
  });

  fs.writeFileSync(file, JSON.stringify(current, null, 2));

  console.log("PROXY_ADDRESS=", proxyAddress);
  if (implAddress) console.log("IMPLEMENTATION_ADDRESS=", implAddress);
  else console.log("IMPLEMENTATION_ADDRESS=unavailable_yet");
  console.log(`Saved deployment to ${file}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
