// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library LibRKVSTReceiptTokensStorage {
    struct Store {
        uint256 initialised;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256(
            "RKVSTReceiptStorageStorage.github/robinbryce/rkvst-event-tokens"
        );

    function store()
        internal
        pure
        returns (LibRKVSTReceiptTokensStorage.Store storage s)
    {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            s.slot := slot
        }
    }

    function _idempotentInit() internal {
        LibRKVSTReceiptTokensStorage.Store
            storage s = LibRKVSTReceiptTokensStorage.store();
        if (s.initialised == uint256(STORAGE_SLOT)) return;

        // TODO: initialisation
        s.initialised = uint256(STORAGE_SLOT);
    }
}
