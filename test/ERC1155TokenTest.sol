// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyERC1155Token.sol";

contract ERC1155TokenTest is Test {
    MyERC1155Token token;
    address user;

    function setUp() public {
        token = new MyERC1155Token("https://example.com/metadata/{id}.json");
        user = address(0x456);
        vm.deal(user, 10 ether);
    }

    function testBuyTokens() public {
        vm.prank(user);
        token.buyTokens{value: 0.5 ether}(10);
        uint256 balance = token.balanceOf(user, token.TOKEN_ID());
        assertEq(balance, 10);
    }
}
