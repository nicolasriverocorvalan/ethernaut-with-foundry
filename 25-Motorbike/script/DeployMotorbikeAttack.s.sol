// SPDX-License-Identifier: MIT

pragma solidity <0.7.0;

import "forge-std/Script.sol";
import {MotorbikeAttack} from"../src/MotorbikeAttack.sol";

contract DeployMotorbikeAttack is Script {
    MotorbikeAttack motorbikeAttack;

    function run() external{
        vm.startBroadcast();

        motorbikeAttack = new MotorbikeAttack();
        
        vm.stopBroadcast();
    }
}
