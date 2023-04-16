import hre from "hardhat";
import fs from "fs";
import {
  DiamondDeployer,
  FacetCutOpts,
  FileReader,
  Reporter,
} from "@polysensus/diamond-deploy";

const DIAMOND_DEPLOY_JSON =
  process.env.DIAMOND_DEPLOY_JSON ?? "dist/diamond-deploy.json";

// import hre from "hardhat";
// import { DiamondDeployer, FacetCutOpts, FileReader } from "@polysensus/diamond-deploy";

export function readJson(filename) {
  return JSON.parse(fs.readFileSync(filename, "utf-8"));
}

export async function deployRKVSTEventTokensFixture() {
  const [deployer, owner] = await hre.ethers.getSigners();
  const proxy = await deployRKVSTEventTokens(deployer, owner, {});
  return [proxy, owner];
}

export async function deployRKVSTEventTokens(signer, owner, options = {}) {
  options.diamondOwner = owner;
  options.diamondLoupeName = "DiamondLoupeFacet";
  options.diamondCutName = "DiamondCutFacet";
  options.diamondInitName = "DiamondNew";
  options.diamondInitArgs = '[{"typeURIs": ["ASSET", "EVENT"]}]';

  const cuts = readJson(options.facets ?? DIAMOND_DEPLOY_JSON).map(
    (o) => new FacetCutOpts(o)
  );

  const deployer = new DiamondDeployer(
    new Reporter(console.log, console.log, console.log),
    signer,
    { FileReader: new FileReader() },
    options
  );
  await deployer.processERC2535Cuts(cuts);
  await deployer.processCuts(cuts);
  if (!deployer.canDeploy())
    throw new Error(
      `can't deploy contracts, probably missing artifacts or facets`
    );
  const result = await deployer.deploy();
  if (result.isErr()) throw new Error(result.errmsg());
  if (!result.address)
    throw new Error("no adddress on result for proxy deployment");

  return result.address;
}
