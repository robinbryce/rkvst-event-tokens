// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStateProofVerifier} from "../interfaces/IStateProofVerifier.sol";

/// @notice return the nft id. for a typed or un-typed nft
/// @dev the instance id lives in the most significant 128 bits
/// @return token the return variables of a contract’s function state variable
function instanceId(uint256 id) pure returns (uint128) {
    return uint128(id >> INSTANCE_SHIFT);
}

function idOf(uint128 value) pure returns (uint256) {
    return uint256(value) << INSTANCE_SHIFT;
}

function withDynamicType(uint256 id) pure returns (uint256) {
    return id | (1 << 16);
}

function receiptToken(uint128 eventIdentity) pure returns (uint256) {
    return withDynamicType(idOf(eventIdentity)) | EVENT_RECEIPT_TYPE;
}

function isReceiptToken(uint256 id) pure returns (bool) {
    return (id & EVENT_RECEIPT_TYPE) != 0;
}

uint256 constant INSTANCE_SHIFT = 128;
uint256 constant INSTANCE_BITS = 128;
uint256 constant EVENT_RECEIPT_TYPE = 1;

library LibRKVSTReceiptTokens {
    // |<------------ 128 -------------->|<-- 32--><-- 32 -->|<- 16 ->|<- 16 ->|
    // |           nft-id  (not typed)   |        0          |    0   |    0   |
    // |           nft-id                |        0          |    0   | static |
    //                                                                | typeid |
    // |           nft-instance-id       |        0          | flags  | 0      |
    // |               0                 | fungible|  resrvd |    0   |    0   |
    //
    // flags 000000000000000001 collection member
    //
    // untyped always represent event receipts
    // static types
    // 1 event receipt
    // 2 event
    // 3 asset
    // note: very tempted to steal the uuid type bits so the event and asset id
    // can be encoded in the token id

    struct TokenInitArgs {
        uint128 eventIdentity;
        string tokenURI;
        address account;
        bytes32 worldRoot;
        bytes rlpAccountProof;
        IStateProofVerifier.EIP1186StorageProofs[] storageProofs;
    }
}
