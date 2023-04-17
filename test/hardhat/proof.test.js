import chai from "chai";
const { expect } = chai;
import hre from "hardhat";
const { ethers } = hre;

const keccak256 = ethers.utils.keccak256;
const bigFrom = ethers.BigNumber.from;

import { deployRKVSTEventTokensFixture } from "./deploy.js";
import { createProxy } from "./proxy.js";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import rkvstreceipt1 from "./data/rkvst-receipt.json" assert { type: "json" };
import rkvstreceipt2 from "./data/rkvst-receipt2.json" assert { type: "json" };
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
    const account = keccak256(ethers.utils.getAddress(rkvstreceipt1.account));

    // see https://github.com/lidofinance/curve-merkle-oracle/blob/1033b3e84142317ffd8f366b52e489d5eb49c73f/offchain/state_proof.py
    // for reference to the translation from eip 1186
    const accountProof = rkvstreceipt1.named_proofs[0].proof.accountProof.map(
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
      rkvstreceipt1.named_proofs[0].proof.storageProof[0].key
    );
    const storageRootHash = rkvstreceipt1.named_proofs[0].proof.storageHash;
    // see https://github.com/lidofinance/curve-merkle-oracle/blob/1033b3e84142317ffd8f366b52e489d5eb49c73f/offchain/state_proof.py
    // for reference to the translation from eip 1186
    const proof = rkvstreceipt1.named_proofs[0].proof.storageProof[0].proof.map(
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

  it("Should verify an eip 1186 proof list with one element", async function () {
    [proxyAddress, ownerAddress] = await loadFixture(
      deployRKVSTEventTokensFixture
    );
    const tokens = createProxy(proxyAddress, ownerAddress);
    expect(tokens).to.exist;

    const eip1186Proof = rkvstreceipt1.named_proofs[0].proof;

    const accountAddressHash = keccak256(
      ethers.utils.getAddress(rkvstreceipt1.account)
    );

    // see https://github.com/lidofinance/curve-merkle-oracle/blob/1033b3e84142317ffd8f366b52e489d5eb49c73f/offchain/state_proof.py
    // for reference to the translation from eip 1186
    const accountProof = eip1186Proof.accountProof.map((node) =>
      ethers.utils.RLP.decode(node)
    );

    const rlpAccountProof = ethers.utils.RLP.encode(accountProof);

    const slotKeyHashes = [];
    const rlpStorageProofs = [];
    for (const proof of eip1186Proof.storageProof) {
      slotKeyHashes.push(keccak256(proof.key));
      const decodedProof = proof.proof.map((node) =>
        ethers.utils.RLP.decode(node)
      );
      rlpStorageProofs.push(ethers.utils.RLP.encode(decodedProof));
    }

    const storageProofs = {
      storageHash: eip1186Proof.storageHash,
      slotKeyHashes,
      rlpStorageProofs,
    };

    const accountState = await tokens.batchVerifyEIP1186Proof(
      accountAddressHash,
      worldRoot,
      rlpAccountProof,
      [storageProofs]
    );

    expect(accountState?.exists).to.be.true;
  });

  it("Should mint a receipt token", async function () {
    [proxyAddress, ownerAddress] = await loadFixture(
      deployRKVSTEventTokensFixture
    );
    const tokens = createProxy(proxyAddress, ownerAddress);
    expect(tokens).to.exist;

    const eip1186Proof = rkvstreceipt1.named_proofs[0].proof;

    const account = ethers.utils.getAddress(rkvstreceipt1.account);

    // see https://github.com/lidofinance/curve-merkle-oracle/blob/1033b3e84142317ffd8f366b52e489d5eb49c73f/offchain/state_proof.py
    // for reference to the translation from eip 1186
    const accountProof = eip1186Proof.accountProof.map((node) =>
      ethers.utils.RLP.decode(node)
    );

    const rlpAccountProof = ethers.utils.RLP.encode(accountProof);

    const slotKeyHashes = [];
    const rlpStorageProofs = [];
    for (const proof of eip1186Proof.storageProof) {
      slotKeyHashes.push(keccak256(proof.key));
      const decodedProof = proof.proof.map((node) =>
        ethers.utils.RLP.decode(node)
      );
      rlpStorageProofs.push(ethers.utils.RLP.encode(decodedProof));
    }

    const storageProofs = {
      storageHash: eip1186Proof.storageHash,
      slotKeyHashes,
      rlpStorageProofs,
    };

    const tx = await tokens.createReceiptToken(
      bigFrom("0x01"), // eventIdentity:
      "a-token-{id}", // tokenURL:
      account,
      worldRoot,
      rlpAccountProof,
      [storageProofs]
    );

    const r = await tx.wait();
    const iface = tokens.getFacetInterface("ERC1155Facet");
    const event = iface.parseLog(r.logs[0]);
    const hardhat1Address = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";
    expect(event.name).to.equal("TransferSingle");
    expect(event.args.to).to.equal(hardhat1Address);
    expectGoodStatus(r);
  });
  it("Should mint proving all named proofs", async function () {
    [proxyAddress, ownerAddress] = await loadFixture(
      deployRKVSTEventTokensFixture
    );
    const tokens = createProxy(proxyAddress, ownerAddress);
    expect(tokens).to.exist;

    const eip1186Proof2 = rkvstreceipt2.named_proofs[0].proof;

    const account = ethers.utils.getAddress(rkvstreceipt2.account);

    // see https://github.com/lidofinance/curve-merkle-oracle/blob/1033b3e84142317ffd8f366b52e489d5eb49c73f/offchain/state_proof.py
    // for reference to the translation from eip 1186
    const accountProof = eip1186Proof2.accountProof.map((node) =>
      ethers.utils.RLP.decode(node)
    );

    const rlpAccountProof = ethers.utils.RLP.encode(accountProof);

    const storageProofs = [];
    for (const namedProof of rkvstreceipt2.named_proofs) {
      const slotKeyHashes = [];
      const rlpStorageProofs = [];
      for (const proof of namedProof.proof.storageProof) {
        slotKeyHashes.push(keccak256(proof.key));
        const decodedProof = proof.proof.map((node) =>
          ethers.utils.RLP.decode(node)
        );
        rlpStorageProofs.push(ethers.utils.RLP.encode(decodedProof));
      }

      storageProofs.push({
        storageHash: namedProof.proof.storageHash,
        slotKeyHashes,
        rlpStorageProofs,
      });
    }

    const tx = await tokens.createReceiptToken(
      bigFrom("0x01"), // eventIdentity:
      "a-token-{id}", // tokenURL:
      account,
      worldRoot,
      rlpAccountProof,
      storageProofs
    );

    const r = await tx.wait();
    const iface = tokens.getFacetInterface("ERC1155Facet");
    const event = iface.parseLog(r.logs[0]);
    const hardhat1Address = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";
    expect(event.name).to.equal("TransferSingle");
    expect(event.args.to).to.equal(hardhat1Address);
    expectGoodStatus(r);
  });
});

function expectGoodStatus(r, msg) {
  expect(r.status).to.be.equal(1, msg ?? "transaction not successful");
}
