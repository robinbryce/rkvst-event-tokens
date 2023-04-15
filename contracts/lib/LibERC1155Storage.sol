// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library LibERC1155Storage {
    struct Store {
        uint256 initialised;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("ERC1155Storage.github/robinbryce/rkvst-event-tokens");

    function store() internal pure returns (LibERC1155Storage.Store storage s) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            s.slot := slot
        }
    }

    function _idempotentInit() internal {
        LibERC1155Storage.Store storage s = LibERC1155Storage.store();
        if (s.initialised == uint256(STORAGE_SLOT)) return;

        // TODO: initialisation
        s.initialised = uint256(STORAGE_SLOT);
    }
}
