// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyERC721Token.sol";

contract ERC721TokenTest is Test {
    MyERC721Token token;
    address user;

    function setUp() public {
        token = new MyERC721Token("https://example.com/metadata/");
        user = address(0x456);
        vm.deal(user, 10 ether);
    }

    function testBuyToken() public {
        vm.prank(user);
        token.buyToken{value: 0.1 ether}();
        uint256 tokenId = 0;
        assertEq(token.ownerOf(tokenId), user);
        string memory tokenURI = token.tokenURI(tokenId);
        assertEq(tokenURI, string(abi.encodePacked("https://example.com/metadata/", Strings.toString(tokenId))));
    }
}
