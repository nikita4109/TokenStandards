// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/**
 * @title MyERC1155Token
 * @dev ERC1155 Token with purchase function and metadata
 */
contract MyERC1155Token is ERC1155 {
    uint256 public constant TOKEN_ID = 0;
    uint256 public constant TOKEN_PRICE = 5e16; // 0.05 ETH per token

    /**
     * @notice Constructor to create the token
     * @param uri URI for token metadata
     */
    constructor(string memory uri) ERC1155(uri) {
        _mint(address(this), TOKEN_ID, 10000, "");
    }

    /**
     * @notice Purchase tokens by sending ETH
     * @param amount Amount of tokens to purchase
     */
    function buyTokens(uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than zero");
        require(msg.value >= amount * TOKEN_PRICE, "Not enough ETH sent");
        uint256 contractBalance = balanceOf(address(this), TOKEN_ID);
        require(amount <= contractBalance, "Not enough tokens available");
        _safeTransferFrom(address(this), msg.sender, TOKEN_ID, amount, "");
    }

    /**
     * @notice Set the URI for metadata
     * @param newuri New URI string
     */
    function setURI(string memory newuri) external {
        _setURI(newuri);
    }
}
