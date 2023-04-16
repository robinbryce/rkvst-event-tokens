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

    function verifyEIP1186(
        bytes32 _accountHash,
        bytes32 _stateRootHash,
        bytes32 _storageHash,
        bytes calldata _rlpAccountProof,
        bytes32[] calldata _slotKeyHashes,
        bytes[] calldata _rlpStorageProofs
    ) external pure returns (Account memory) {
        return
            LibStateProofVerifier.verifyEIP1186(
                _accountHash,
                _stateRootHash,
                _storageHash,
                _rlpAccountProof,
                _slotKeyHashes,
                _rlpStorageProofs
            );
    }
}
