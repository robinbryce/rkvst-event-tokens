// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library LibRKVSTReceiptTokensStorage {
    struct Layout {
        uint256 initialised;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256(
            "RKVSTReceiptStorageStorage.github/robinbryce/rkvst-event-tokens"
        );

    function layout()
        internal
        pure
        returns (LibRKVSTReceiptTokensStorage.Layout storage s)
    {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            s.slot := slot
        }
    }

    function _idempotentInit() internal {
        LibRKVSTReceiptTokensStorage.Layout
            storage s = LibRKVSTReceiptTokensStorage.layout();
        if (s.initialised == uint256(STORAGE_SLOT)) return;

        // TODO: initialisation
        s.initialised = uint256(STORAGE_SLOT);
    }
}
