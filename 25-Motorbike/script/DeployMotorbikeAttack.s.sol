// SPDX-License-Identifier: MIT

pragma solidity <0.7.0;

import "forge-std/Script.sol";
import {MotorbikeAttack} from "../src/MotorbikeAttack.sol";

contract DeployMotorbikeAttack is Script {

    function run() external returns (MotorbikeAttack){
        vm.startBroadcast();

        MotorbikeAttack motorbikeAttack = new MotorbikeAttack(address(0x0fE5D6cf6cBc49a3ce61fdE297fC335451FB1757));
        motorbikeAttack.attack();

        vm.stopBroadcast();
        return motorbikeAttack;
    }
}
