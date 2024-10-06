// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @title MyERC20Token
 * @dev ERC20 Token with purchase function, transfer fee, and Permit functionality.
 */
contract MyERC20Token is ERC20Permit {
    uint256 public constant TOKEN_PRICE = 1e16; // 0.01 ETH per token
    uint256 public transferFee = 100; // Fee is 1%, denominator is 10000

    address public feeRecipient;

    /**
     * @notice Constructor to create the token
     * @param _feeRecipient Address that will receive the transfer fees
     */
    constructor(address _feeRecipient) ERC20("MyToken", "MTK") ERC20Permit("MyToken") {
        feeRecipient = _feeRecipient;
        _mint(address(this), 1e24); // Mint 1 million tokens to the contract
    }

    /**
     * @notice Purchase tokens by sending ETH
     */
    function buyTokens() external payable {
        require(msg.value > 0, "Send ETH to buy tokens");
        uint256 amountToBuy = (msg.value * 1e18) / TOKEN_PRICE;
        uint256 contractBalance = balanceOf(address(this));
        require(amountToBuy <= contractBalance, "Not enough tokens available");
        _transfer(address(this), msg.sender, amountToBuy);
    }

    /**
     * @notice Override transfer to include transfer fee
     * @param recipient Recipient address
     * @param amount Amount to transfer
     * @return Success boolean
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * transferFee) / 10000;
        uint256 amountAfterFee = amount - fee;

        _transfer(_msgSender(), feeRecipient, fee);
        _transfer(_msgSender(), recipient, amountAfterFee);
        return true;
    }

    /**
     * @notice Override transferFrom to include transfer fee
     * @param sender Sender address
     * @param recipient Recipient address
     * @param amount Amount to transfer
     * @return Success boolean
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * transferFee) / 10000;
        uint256 amountAfterFee = amount - fee;

        _transfer(sender, feeRecipient, fee);
        _transfer(sender, recipient, amountAfterFee);

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
}
