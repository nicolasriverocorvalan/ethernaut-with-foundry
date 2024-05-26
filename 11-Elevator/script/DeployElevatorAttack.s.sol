// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {ElevatorAttack} from "../src/ElevatorAttack.sol";

contract DeployElevatorAttack is Script {
    address private constant ELEVATOR_ADDRESS = 0xdfDdeaC38D65688eB0979f8B52c09Db7529c6Ce6; //Elevator contract to attack

    function run() external returns (ElevatorAttack) {
        vm.startBroadcast();

        ElevatorAttack elevatorAttack = new ElevatorAttack(ELEVATOR_ADDRESS);

        vm.stopBroadcast();
        return elevatorAttack;
    }    
}
