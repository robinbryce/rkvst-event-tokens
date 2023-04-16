// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * A pure facet that verifies an EIP 1186 style merkle patricial proof in the
 * EVM.
 */

import {RLPReader} from "solidity-rlp/contracts/RLPReader.sol";
import {IStateProofVerifier} from "../interfaces/IStateProofVerifier.sol";
import {LibStateProofVerifier} from "../lib/LibStateProofVerifier.sol";

contract StateProofVerifierFacet is IStateProofVerifier {
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for bytes;

    /*
    function verifyEIP1186Proof(
        bytes32 _accountHash,
        bytes32 _stateRootHash,
        IStateProofVerifier.EIP1186Proof calldata proof
    ) external pure returns (Account memory) {
        return
            LibStateProofVerifier.verifyEIP1186Proof(
                _accountHash,
                _stateRootHash,
                proof
            );
    }*/

    function batchVerifyEIP1186Proof(
        bytes32 _accountHash,
        bytes32 _stateRootHash,
        bytes calldata rlpAccountProof,
        EIP1186StorageProofs[] calldata storageProofs
    ) external pure returns (Account memory) {
        return
            LibStateProofVerifier.batchVerifyEIP1186Proof(
                _accountHash,
                _stateRootHash,
                rlpAccountProof,
                storageProofs
            );
    }

    function proveAccountState(
        bytes32 _accountHash,
        bytes32 _stateRootHash,
        bytes calldata _rlpProof
    ) external pure returns (Account memory) {
        return
            LibStateProofVerifier.proveAccountState(
                _accountHash,
                _stateRootHash,
                _rlpProof
            );
    }

    function proveSlotValue(
        bytes32 _slotHash,
        bytes32 _storageRootHash,
        bytes calldata _rlpProof
    ) external pure returns (SlotValue memory) {
        return
            LibStateProofVerifier.proveSlotValue(
                _slotHash,
                _storageRootHash,
                _rlpProof
            );
    }
}
