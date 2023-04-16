// const { expect } = require("chai")
// const { ethers } = require("hardhat")
import chai from 'chai'
const { expect } = chai
import hre from 'hardhat'
const { ethers } = hre
import { deployRKVSTEventTokensFixture } from "./deploy.js";

import { createProxy } from './proxy.js'

import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';

describe("Deploy", function () {
  let proxy;
  let owner;

  it("Should deploy new diamond", async function () {

    [proxy, owner] = await loadFixture(deployRKVSTEventTokensFixture);
    const tokens = createProxy(proxy, owner);
    expect(tokens).to.exist;
  })
})
