// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IERC1155} from "@solidstate/contracts/interfaces/IERC1155.sol";
import {ERC1155Base} from "@solidstate/contracts/token/ERC1155/base/ERC1155Base.sol";
import {SolidStateERC1155} from "@solidstate/contracts/token/ERC1155/SolidStateERC1155.sol";
import {ERC1155MetadataStorage} from "@solidstate/contracts/token/ERC1155/metadata/ERC1155Metadata.sol";

import {IRKVSTReceiptTokens} from "../interfaces/IRKVSTReceiptTokens.sol";

import {ModPausable} from "../lib/solidstate/security/ModPausable.sol";
import {ModOwnable} from "../lib/solidstate/access/ownable/ModOwnable.sol";
import {ContextMixin} from "../lib/contextmixin.sol";
import {LibERC1155Storage} from "../lib/LibERC1155Storage.sol";
import {LibRKVSTReceiptTokens, receiptToken, isReceiptToken} from "../lib/LibRKVSTReceiptTokens.sol";
import {LibRKVSTReceiptTokensStorage} from "../lib/LibRKVSTReceiptTokensStorage.sol";

import {IStateProofVerifier} from "../interfaces/IStateProofVerifier.sol";
import {LibStateProofVerifier} from "../lib/LibStateProofVerifier.sol";

error NotYetImplemented();
error MintDataAbsent();
error MintDataLength();
error RecipientReceiptExists();
error OneReceiptPerRecipient();

contract ERC1155Facet is
    IRKVSTReceiptTokens,
    SolidStateERC1155,
    ModOwnable,
    ModPausable,
    ContextMixin
{
    struct MintData {
        bytes32 accountHash;
        bytes32 worldRoot;
        bytes rlpAccountProof;
        IStateProofVerifier.EIP1186StorageProofs[] storageProofs;
    }

    /// @notice creates a new receipt token
    /// @return returns the token id
    function createReceiptToken(
        // LibRKVSTReceiptTokens.TokenInitArgs calldata initArgs
        uint128 eventIdentity,
        string calldata tokenURI,
        address account,
        bytes32 worldRoot,
        bytes calldata rlpAccountProof,
        IStateProofVerifier.EIP1186StorageProofs[] calldata storageProofs
    ) public whenNotPaused returns (uint256) {
        MintData[] memory mintData = new MintData[](1);
        mintData[0].accountHash = keccak256(abi.encodePacked(account));
        mintData[0].worldRoot = worldRoot;
        mintData[0].rlpAccountProof = rlpAccountProof;
        mintData[0].storageProofs = storageProofs;
        bytes memory data = abi.encode(mintData);

        uint256 id = receiptToken(eventIdentity);
        _mint(_msgSender(), id, 1, data);

        return id;
    }

    /**
     * @dev This is used instead of msg.sender as transactions won't be sent by
     * the original token owner, but by OpenSea.
     * ref: https://docs.opensea.io/docs/polygon-basic-integration
     */
    function _msgSender() internal view returns (address sender) {
        return ContextMixin.msgSender();
    }

    function setURI(string memory newuri) public whenNotPaused onlyOwner {
        ERC1155MetadataStorage.layout().baseURI = newuri;
    }

    /* Don't currently support a general mint
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public whenNotPaused onlyOwner {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public whenNotPaused onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }
    */

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data // whenNotPaused
    ) internal override {
        if (from != address(0)) {
            super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
            return;
        }

        MintData[] memory mintData = abi.decode(data, (MintData[]));
        if (mintData.length != ids.length) revert MintDataLength();

        for (uint i; i < ids.length; i++) {
            if (isReceiptToken(ids[i])) continue;

            // receipt tokens are 1 per owner
            uint256 balance = _balanceOf(to, ids[i]);
            if (balance != 0) revert RecipientReceiptExists();
            if (amounts[i] != 1) revert OneReceiptPerRecipient();

            LibStateProofVerifier.batchVerifyEIP1186Proof(
                mintData[i].accountHash,
                mintData[i].worldRoot,
                mintData[i].rlpAccountProof,
                mintData[i].storageProofs
            );
        }

        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    /**
     @dev https://ethereum.stackexchange.com/questions/56749/retrieve-chain-id-of-the-executing-chain-from-a-solidity-contract
     */
    function getChainID() internal view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    /**
     * Override isApprovedForAll to auto-approve OS's proxy contract
     */
    function isApprovedForAll(
        address _owner,
        address _operator
    )
        public
        view
        override(ERC1155Base, IERC1155)
        returns (
            // whenNotPaused
            bool isOperator
        )
    {
        // If OpenSea's ERC1155 proxy on the Polygon Mumbai test net
        if (
            getChainID() == uint256(80001) &&
            _operator == address(0x53d791f18155C211FF8b58671d0f7E9b50E596ad)
        ) {
            return true;
        }
        // If OpenSea's ERC1155 proxy on the Polygon  main net
        if (
            getChainID() == uint256(137) &&
            _operator == address(0x207Fa8Df3a17D96Ca7EA4f2893fcdCb78a304101)
        ) {
            return true;
        }
        // otherwise, use the default ERC1155.isApprovedForAll()
        return super.isApprovedForAll(_owner, _operator);
    }
}
