// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// DiamondNew should only be used on a freshly deployed (empty) chaintrap diamond

import {LibDiamond} from "../lib/LibDiamond.sol";
import {IDiamondLoupe} from "../interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import {IERC165} from "../interfaces/IERC165.sol";

// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

import {LibERC1155Storage} from "../lib/LibERC1155Storage.sol";
import {LibRKVSTReceiptTokensStorage} from "../lib/LibRKVSTReceiptTokensStorage.sol";

struct DiamondNewArgs {
    string[] typeURIs;
}

interface IDiamondNew {
    function init(DiamondNewArgs calldata args) external;
}

contract DiamondNew {
    function init(DiamondNewArgs calldata args) external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;

        LibRKVSTReceiptTokensStorage._idempotentInit();
        LibERC1155Storage._idempotentInit(args.typeURIs);
    }
}
