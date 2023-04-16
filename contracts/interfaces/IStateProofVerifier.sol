// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {RLPReader} from "solidity-rlp/contracts/RLPReader.sol";

interface IStateProofVerifier {
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

    function proveAccountState(
        address _address,
        bytes32 _stateRootHash,
        bytes calldata _rlpProof
    ) external pure returns (Account memory);

    function proveSlotValue(
        bytes32 _slotKey,
        bytes32 _storageRootHash,
        bytes calldata _rlpProof
    ) external pure returns (SlotValue memory);
}
