// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyERC20Token.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ERC20TokenTest is Test {
    MyERC20Token token;
    address user;
    address feeRecipient;

    function setUp() public {
        feeRecipient = address(0x123);
        token = new MyERC20Token(feeRecipient);
        user = address(0x456);
        vm.deal(user, 10 ether);
    }

    function testBuyTokens() public {
        vm.prank(user);
        token.buyTokens{value: 1 ether}();
        uint256 userBalance = token.balanceOf(user);
        assertEq(userBalance, (1 ether * 1e18) / 1e16); // TOKEN_PRICE is 0.01 ETH per token
    }

    function testTransferWithFee() public {
        vm.prank(user);
        token.buyTokens{value: 1 ether}();

        uint256 userBalance = token.balanceOf(user);

        // Transfer half of the user's balance
        uint256 amount = userBalance / 2;
        address recipient = address(0x789);
        vm.prank(user);
        token.transfer(recipient, amount);

        uint256 fee = (amount * token.transferFee()) / 10000;
        uint256 amountAfterFee = amount - fee;

        assertEq(token.balanceOf(recipient), amountAfterFee);
        assertEq(token.balanceOf(feeRecipient), fee);
    }

    function testPermit() public {
        uint256 privateKey = 0xABCDEF;
        address owner = vm.addr(privateKey);

        // Mint tokens to owner
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        token.buyTokens{value: 1 ether}();

        uint256 ownerBalance = token.balanceOf(owner);

        // Transfer half of the owner's balance
        uint256 amount = ownerBalance / 2;

        // Generate permit
        uint256 nonce = token.nonces(owner);
        uint256 deadline = block.timestamp + 1 days;

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                owner,
                address(this),
                amount,
                nonce,
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", token.DOMAIN_SEPARATOR(), structHash)
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        // Use permit to approve tokens
        token.permit(owner, address(this), amount, deadline, v, r, s);

        // Transfer tokens using transferFrom
        token.transferFrom(owner, address(this), amount);

        uint256 expectedBalance = (amount * (10000 - token.transferFee())) / 10000;
        assertEq(token.balanceOf(address(this)), expectedBalance);
    }
}
