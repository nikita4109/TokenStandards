// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title MyERC721Token
 * @dev ERC721 Token with purchase function and metadata
 */
contract MyERC721Token is ERC721 {
    using Strings for uint256;

    uint256 public tokenCounter;
    uint256 public constant TOKEN_PRICE = 1e17; // 0.1 ETH per token
    string public baseURI;

    /**
     * @notice Constructor to create the token
     * @param initialBaseURI Base URI for token metadata
     */
    constructor(string memory initialBaseURI) ERC721("MyNFT", "MNFT") {
        baseURI = initialBaseURI;
        tokenCounter = 0;
    }

    /**
     * @notice Purchase an NFT by sending ETH
     */
    function buyToken() external payable {
        require(msg.value >= TOKEN_PRICE, "Not enough ETH sent");
        _safeMint(msg.sender, tokenCounter);
        tokenCounter += 1;
    }

    /**
     * @notice Override _baseURI to return the base URI
     * @return Base URI string
     */
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /**
     * @notice Set the base URI for metadata
     * @param _newBaseURI New base URI string
     */
    function setBaseURI(string memory _newBaseURI) external {
        baseURI = _newBaseURI;
    }
}
