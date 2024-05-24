// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import {Script} from "forge-std/Script.sol";
import {ReentrancyAttack} from "../src/ReentrancyAttack.sol";
import {Reentrancy} from "../src/Reentrancy.sol";

contract DeployReentrancyAttack is Script {
    address payable private constant REENTRANCY_ADDRESS = 0xfC18C2C05c4B4fFD9Ca97c9A752106d56d4e3E91; //Reentrancy contract to attack

    function run() external returns (ReentrancyAttack) {
        vm.startBroadcast();

        ReentrancyAttack reentrancyAttack = new ReentrancyAttack(REENTRANCY_ADDRESS);

        vm.stopBroadcast();
        return reentrancyAttack;
    }    
}
