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
  const owner = process.env.OWNER_ADDRESS || signer.address;
  const verifier = process.env.VERIFIER_ADDRESS || ethers.ZeroAddress;
  const chainId = Number((await ethers.provider.getNetwork()).chainId);
  const file = fileFor(chainId);

  fs.mkdirSync(path.dirname(file), { recursive: true });
  const current = readJson(file);
  const last = current.length ? current[current.length - 1] : undefined;

  const force = (process.env.FORCE_DEPLOY || "").toLowerCase() === "true";
  if (last && last.proxy && !force) {
    console.log("Existing proxy:", last.proxy);
    console.log("Set FORCE_DEPLOY=true to deploy a new proxy");
    return;
  }

  const ProofPay = await ethers.getContractFactory("ProofPay");
  const proxy = await upgrades.deployProxy(ProofPay, [owner, verifier], { kind: "uups" });
  await proxy.waitForDeployment();

  const proxyAddress = await proxy.getAddress();
  const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
  const block = await ethers.provider.getBlock("latest");

  const entry: Entry = {
    network: network.name,
    chainId,
    proxy: proxyAddress,
    implementation: implAddress,
    deployer: await signer.getAddress(),
    txBlock: block?.number || null,
    timestamp: Number(block?.timestamp || 0),
    commit: process.env.GITHUB_SHA || ""
  };

  const next = [...current, entry];
  fs.writeFileSync(file, JSON.stringify(next, null, 2));

  console.log("PROXY_ADDRESS=", proxyAddress);
  console.log("IMPLEMENTATION_ADDRESS=", implAddress);
  console.log("Saved deployment to", file);
}

main().catch((e) => { console.error(e); process.exit(1); });
