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
        address _address,
        bytes32 _stateRootHash,
        bytes calldata _rlpProof
    ) external pure returns (Account memory) {
        RLPReader.RLPItem[] memory proof = _rlpProof.toRlpItem().toList();
        bytes32 _addressHash = keccak256(abi.encodePacked(_address));

        return
            LibStateProofVerifier.extractAccountFromProof(
                _addressHash,
                _stateRootHash,
                proof
            );
    }

    function proveSlotValue(
        bytes32 _slotKey,
        bytes32 _storageRootHash,
        bytes calldata _rlpProof
    ) external pure returns (SlotValue memory) {
        RLPReader.RLPItem[] memory proof = _rlpProof.toRlpItem().toList();
        bytes32 slotHash = keccak256(bytes.concat(_slotKey));
        return
            LibStateProofVerifier.extractSlotValueFromProof(
                slotHash,
                _storageRootHash,
                proof
            );
    }
}
