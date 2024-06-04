// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {RecoveryAttack} from "../src/RecoveryAttack.sol";

contract DeployRecoveryAttack is Script {
    address private constant RECOVERY_ADDRESS = 0x8f0ba6976574d9c1f67b60a1dAcD966bAac95123; // Recovery contract to attack

    function run() external returns (RecoveryAttack) {
        vm.startBroadcast();

        RecoveryAttack recoveryAttack = new RecoveryAttack(RECOVERY_ADDRESS);

        vm.stopBroadcast();
        return recoveryAttack;
    }    
}
