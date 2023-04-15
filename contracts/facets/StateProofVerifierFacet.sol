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
    function proveAccountState(
        bytes32 _addressHash, // keccak256(abi.encodePacked(address))
        bytes32 _stateRootHash,
        RLPReader.RLPItem[] memory _proof
    ) external pure returns (Account memory) {
        return
            LibStateProofVerifier.extractAccountFromProof(
                _addressHash,
                _stateRootHash,
                _proof
            );
    }

    function proveSlotValue(
        bytes32 _slotHash,
        bytes32 _storageRootHash,
        RLPReader.RLPItem[] memory _proof
    ) external pure returns (SlotValue memory) {
        return
            LibStateProofVerifier.extractSlotValueFromProof(
                _slotHash,
                _storageRootHash,
                _proof
            );
    }
}
