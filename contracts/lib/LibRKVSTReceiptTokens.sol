// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStateProofVerifier} from "../interfaces/IStateProofVerifier.sol";

function eventID(uint256 id) pure returns (uint128) {
    return uint128(id & 0xffffffffffffffffffffffffffffffff);
}

function receiptToken(
    uint128 _receiptNonce,
    uint128 _eventID
) pure returns (uint256) {
    return ((uint256(_receiptNonce) << INSTANCE_SHIFT) | _eventID);
}

uint256 constant INSTANCE_SHIFT = 128;

library LibRKVSTReceiptTokens {
    // |<------------ 128 -------------->|<------------ 128 -------------->|
    // |           event id              |       receipt counter           |

    struct TokenInitArgs {
        uint128 eventIdentity;
        string tokenURI;
        address account;
        bytes32 worldRoot;
        bytes rlpAccountProof;
        IStateProofVerifier.EIP1186StorageProofs[] storageProofs;
    }
}
