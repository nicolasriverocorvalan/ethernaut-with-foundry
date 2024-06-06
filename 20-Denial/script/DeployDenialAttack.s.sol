// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {DenialAttack} from "../src/DenialAttack.sol";

contract DeployPreservationAttack is Script {
    address private constant DENIAL_ADDRESS = 0x5ffA65421367da21332b41cD7f383CeCaB015FD5; // Denial contract to attack

    function run() external returns (DenialAttack) {
        vm.startBroadcast();

        DenialAttack denialAttack = new DenialAttack(DENIAL_ADDRESS);

        vm.stopBroadcast();
        return denialAttack;
    }    
}
