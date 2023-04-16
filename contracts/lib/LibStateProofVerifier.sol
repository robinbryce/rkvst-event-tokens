// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * Copied from https://raw.githubusercontent.com/lidofinance/curve-merkle-oracle/1033b3e84142317ffd8f366b52e489d5eb49c73f/contracts/StateProofVerifier.sol
 * Modified for sol 0.8.18+. The curve-merkle-oracle repository, and including
 * its dependency on Solidity-RLP has previously been audited.
 *
 * NOTICE: This modified copy has not been audited. The changes are
 * - minor: rename to fit local repo conventions
 * - minor: account for renamed LibMerklePatriciaProofVerifier
 * - medium: moved the structs to IStateProofVerifier
 */

import {IStateProofVerifier} from "../interfaces/IStateProofVerifier.sol";
import {RLPReader} from "solidity-rlp/contracts/RLPReader.sol";
import {LibMerklePatriciaProofVerifier} from "./LibMerklePatriciaProofVerifier.sol";

error EIP1186StorageValueMissing(uint256 which);

/**
 * @title A helper library for verification of Merkle Patricia account and state proofs.
 */
library LibStateProofVerifier {
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for bytes;

    uint256 constant HEADER_STATE_ROOT_INDEX = 3;
    uint256 constant HEADER_NUMBER_INDEX = 8;
    uint256 constant HEADER_TIMESTAMP_INDEX = 11;

    function verifyEIP1186(
        bytes32 _accountHash,
        bytes32 _stateRootHash,
        bytes32 _storageHash,
        bytes calldata _rlpAccountProof,
        bytes32[] calldata _slotKeyHashes,
        bytes[] calldata _rlpStorageProofs
    ) internal pure returns (IStateProofVerifier.Account memory) {
        if (_slotKeyHashes.length != _rlpStorageProofs.length)
            revert("slotKey count must match storage proof count");

        IStateProofVerifier.Account memory account = LibStateProofVerifier
            .proveAccountState(_accountHash, _stateRootHash, _rlpAccountProof);
        // Make this a proof of existence, by requiring account.exists
        require(account.exists, "the account does not exist");

        for (uint i; i < _slotKeyHashes.length; i++) {
            IStateProofVerifier.SlotValue
                memory slotValue = LibStateProofVerifier.proveSlotValue(
                    _slotKeyHashes[i],
                    _storageHash,
                    _rlpStorageProofs[i]
                );
            // Make this a proof of existence
            if (!slotValue.exists) revert EIP1186StorageValueMissing(i);
        }
        return account;
    }

    function proveAccountState(
        bytes32 _accountHash,
        bytes32 _stateRootHash,
        bytes calldata _rlpProof
    ) internal pure returns (IStateProofVerifier.Account memory) {
        RLPReader.RLPItem[] memory proof = _rlpProof.toRlpItem().toList();
        return
            LibStateProofVerifier.extractAccountFromProof(
                _accountHash,
                _stateRootHash,
                proof
            );
    }

    function proveSlotValue(
        bytes32 _slotHash,
        bytes32 _storageRootHash,
        bytes calldata _rlpProof
    ) internal pure returns (IStateProofVerifier.SlotValue memory) {
        RLPReader.RLPItem[] memory proof = _rlpProof.toRlpItem().toList();
        return
            LibStateProofVerifier.extractSlotValueFromProof(
                _slotHash,
                _storageRootHash,
                proof
            );
    }

    /**
     * @notice Parses block header and verifies its presence onchain within the latest 256 blocks.
     * @param _headerRlpBytes RLP-encoded block header.
     */
    function verifyBlockHeader(
        bytes memory _headerRlpBytes
    ) internal view returns (IStateProofVerifier.BlockHeader memory) {
        IStateProofVerifier.BlockHeader memory header = parseBlockHeader(
            _headerRlpBytes
        );
        // ensure that the block is actually in the blockchain
        require(header.hash == blockhash(header.number), "blockhash mismatch");
        return header;
    }

    /**
     * @notice Parses RLP-encoded block header.
     * @param _headerRlpBytes RLP-encoded block header.
     */
    function parseBlockHeader(
        bytes memory _headerRlpBytes
    ) internal pure returns (IStateProofVerifier.BlockHeader memory) {
        IStateProofVerifier.BlockHeader memory result;
        RLPReader.RLPItem[] memory headerFields = _headerRlpBytes
            .toRlpItem()
            .toList();

        require(headerFields.length > HEADER_TIMESTAMP_INDEX);

        result.stateRootHash = bytes32(
            headerFields[HEADER_STATE_ROOT_INDEX].toUint()
        );
        result.number = headerFields[HEADER_NUMBER_INDEX].toUint();
        result.timestamp = headerFields[HEADER_TIMESTAMP_INDEX].toUint();
        result.hash = keccak256(_headerRlpBytes);

        return result;
    }

    /**
     * @notice Verifies Merkle Patricia proof of an account and extracts the account fields.
     *
     * @param _addressHash Keccak256 hash of the address corresponding to the account.
     * @param _stateRootHash MPT root hash of the Ethereum state trie.
     */
    function extractAccountFromProof(
        bytes32 _addressHash, // keccak256(abi.encodePacked(address))
        bytes32 _stateRootHash,
        RLPReader.RLPItem[] memory _proof
    ) internal pure returns (IStateProofVerifier.Account memory) {
        bytes memory acctRlpBytes = LibMerklePatriciaProofVerifier
            .extractProofValue(
                _stateRootHash,
                abi.encodePacked(_addressHash),
                _proof
            );

        IStateProofVerifier.Account memory account;

        if (acctRlpBytes.length == 0) {
            return account;
        }

        RLPReader.RLPItem[] memory acctFields = acctRlpBytes
            .toRlpItem()
            .toList();
        require(acctFields.length == 4);

        account.exists = true;
        account.nonce = acctFields[0].toUint();
        account.balance = acctFields[1].toUint();
        account.storageRoot = bytes32(acctFields[2].toUint());
        account.codeHash = bytes32(acctFields[3].toUint());

        return account;
    }

    /**
     * @notice Verifies Merkle Patricia proof of a slot and extracts the slot's value.
     *
     * @param _slotHash Keccak256 hash of the slot position.
     * @param _storageRootHash MPT root hash of the account's storage trie.
     */
    function extractSlotValueFromProof(
        bytes32 _slotHash,
        bytes32 _storageRootHash,
        RLPReader.RLPItem[] memory _proof
    ) internal pure returns (IStateProofVerifier.SlotValue memory) {
        bytes memory valueRlpBytes = LibMerklePatriciaProofVerifier
            .extractProofValue(
                _storageRootHash,
                abi.encodePacked(_slotHash),
                _proof
            );

        IStateProofVerifier.SlotValue memory value;

        if (valueRlpBytes.length != 0) {
            value.exists = true;
            value.value = valueRlpBytes.toRlpItem().toUint();
        }

        return value;
    }
}
