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
        bytes32 _addressHash, // keccak256(abi.encodePacked(address))
        bytes32 _stateRootHash,
        RLPReader.RLPItem[] memory _proof
    ) external pure returns (Account memory);

    function proveSlotValue(
        bytes32 _slotHash,
        bytes32 _storageRootHash,
        RLPReader.RLPItem[] memory _proof
    ) external pure returns (SlotValue memory);
}
