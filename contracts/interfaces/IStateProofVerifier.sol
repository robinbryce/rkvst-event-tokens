// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {RLPReader} from "solidity-rlp/contracts/RLPReader.sol";

interface IStateProofVerifier {
    struct EIP1186StorageProofs {
        bytes32 storageHash;
        bytes32[] slotKeyHashes;
        bytes[] rlpStorageProofs;
    }

    struct BlockHeader {
        bytes32 hash;
        bytes32 stateRootHash;
        uint256 number;
        uint256 timestamp;
    }

    struct Account {
        bool exists;
        uint256 nonce;
        uint256 balance;
        bytes32 storageRoot;
        bytes32 codeHash;
    }

    struct SlotValue {
        bool exists;
        uint256 value;
    }

    /// @notice batchVerify a list of EIP1186 proofs for the same account and
    /// world state root.
    function batchVerifyEIP1186Proof(
        bytes32 _accountHash,
        bytes32 _stateRootHash,
        bytes calldata rlpAccountProof,
        EIP1186StorageProofs[] calldata storageProofs
    ) external pure returns (Account memory);

    function proveAccountState(
        bytes32 _accountHash,
        bytes32 _stateRootHash,
        bytes calldata _rlpProof
    ) external pure returns (Account memory);

    function proveSlotValue(
        bytes32 _slotKeyHash,
        bytes32 _storageRootHash,
        bytes calldata _rlpProof
    ) external pure returns (SlotValue memory);
}
