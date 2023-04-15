// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library LibERC1155Storage {
    struct Layout {
        uint256 initialised;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("ERC1155Storage.github/robinbryce/rkvst-event-tokens");

    function layout()
        internal
        pure
        returns (LibERC1155Storage.Layout storage s)
    {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            s.slot := slot
        }
    }

    function _idempotentInit(string[] calldata /*typeURIs*/) internal {
        LibERC1155Storage.Layout storage s = LibERC1155Storage.layout();
        if (s.initialised == uint256(STORAGE_SLOT)) return;

        // TODO: initialisation
        s.initialised = uint256(STORAGE_SLOT);
    }
}
