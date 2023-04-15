// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./LibERC1155Storage.sol";

library LibERC1155Arena {
    event URI(string value, uint256 indexed tokenId);
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
}
