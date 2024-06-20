// SPDX-License-Identifier: MIT

pragma solidity <0.7.0;

import "forge-std/Script.sol";
import {MotorbikeAttack} from "../src/MotorbikeAttack.sol";

contract DeployMotorbikeAttack is Script {

    function run() external returns (MotorbikeAttack){
        vm.startBroadcast();

        MotorbikeAttack motorbikeAttack = new MotorbikeAttack(address(0xdb62eCf5b813d2E668C4c0fB1502F4B120C22833));
        motorbikeAttack.attack();

        vm.stopBroadcast();
        return motorbikeAttack;
    }
}
