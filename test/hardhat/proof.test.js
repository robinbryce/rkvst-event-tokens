import chai from "chai";
const { expect } = chai;
import hre from "hardhat";
const { ethers } = hre;

const keccak256 = ethers.utils.keccak256;
const bigFrom = ethers.BigNumber.from;

import { deployRKVSTEventTokensFixture } from "./deploy.js";
import { createProxy } from "./proxy.js";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import rkvstreceipt from "./data/rkvst-receipt.json" assert { type: "json" };
import pkg from "./data/rkvst-receipt-worldroot.json" assert { type: "json" };
const { worldRoot } = pkg;
// import eip1186proof from "data/eip1186-proof.json" assert { type: "json" };

describe("Proof", function () {
  let proxyAddress;
  let ownerAddress;

  it("Should verify an account proof", async function () {
    [proxyAddress, ownerAddress] = await loadFixture(
      deployRKVSTEventTokensFixture
    );
    const tokens = createProxy(proxyAddress, ownerAddress);
    expect(tokens).to.exist;
    const account = keccak256(ethers.utils.getAddress(rkvstreceipt.account));

    // see https://github.com/lidofinance/curve-merkle-oracle/blob/1033b3e84142317ffd8f366b52e489d5eb49c73f/offchain/state_proof.py
    // for reference to the translation from eip 1186
    const accountProof = rkvstreceipt.named_proofs[0].proof.accountProof.map(
      (node) => ethers.utils.RLP.decode(node)
    );

    const rlpProof = ethers.utils.RLP.encode(
      // rkvstreceipt.named_proofs[0].proof.accountProof
      accountProof
    );

    const accountState = await tokens.proveAccountState(
      account,
      worldRoot,
      rlpProof
    );
    expect(accountState?.exists).to.be.true;
  });

  it("Should verify a storage proof", async function () {
    [proxyAddress, ownerAddress] = await loadFixture(
      deployRKVSTEventTokensFixture
    );
    const tokens = createProxy(proxyAddress, ownerAddress);
    expect(tokens).to.exist;
    const slotKey = keccak256(
      rkvstreceipt.named_proofs[0].proof.storageProof[0].key
    );
    const storageRootHash = rkvstreceipt.named_proofs[0].proof.storageHash;
    // see https://github.com/lidofinance/curve-merkle-oracle/blob/1033b3e84142317ffd8f366b52e489d5eb49c73f/offchain/state_proof.py
    // for reference to the translation from eip 1186
    const proof = rkvstreceipt.named_proofs[0].proof.storageProof[0].proof.map(
      (node) => ethers.utils.RLP.decode(node)
    );

    const rlpProof = ethers.utils.RLP.encode(proof);

    const slotValue = await tokens.proveSlotValue(
      slotKey,
      storageRootHash,
      rlpProof
    );
    expect(slotValue?.exists).to.be.true;
  });

  it("Should verify an eip 1186 proof", async function () {
    [proxyAddress, ownerAddress] = await loadFixture(
      deployRKVSTEventTokensFixture
    );
    const tokens = createProxy(proxyAddress, ownerAddress);
    expect(tokens).to.exist;

    const eip1186Proof = rkvstreceipt.named_proofs[0].proof;

    const accountAddressHash = keccak256(
      ethers.utils.getAddress(rkvstreceipt.account)
    );

    // see https://github.com/lidofinance/curve-merkle-oracle/blob/1033b3e84142317ffd8f366b52e489d5eb49c73f/offchain/state_proof.py
    // for reference to the translation from eip 1186
    const accountProof = eip1186Proof.accountProof.map((node) =>
      ethers.utils.RLP.decode(node)
    );

    const rlpAccountProof = ethers.utils.RLP.encode(accountProof);

    const slotKeys = [];
    const rlpStorageProofs = [];
    for (const proof of eip1186Proof.storageProof) {
      slotKeys.push(keccak256(proof.key));
      const decodedProof = proof.proof.map((node) => ethers.utils.RLP.decode(node));
      rlpStorageProofs.push(ethers.utils.RLP.encode(decodedProof));
    }

    const accountState = await tokens.verifyEIP1186(
      accountAddressHash,
      worldRoot,
      eip1186Proof.storageHash,
      rlpAccountProof,
      slotKeys,
      rlpStorageProofs
    );
    expect(accountState?.exists).to.be.true;
  });
});

function expectGoodStatus(r, msg) {
  expect(r.status).to.be.equal(1, msg ?? "transaction not successful");
}
