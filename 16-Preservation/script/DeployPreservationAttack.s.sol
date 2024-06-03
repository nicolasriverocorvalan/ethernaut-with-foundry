// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {PreservationAttack} from "../src/PreservationAttack.sol";

contract DeployPreservationAttack is Script {
    address private constant PRESERVATION_ADDRESS = 0xc710338Eaf1765Fcc8944f9792dFc286a47a47FA; // Preservation contract to attack

    function run() external returns (PreservationAttack) {
        vm.startBroadcast();

        PreservationAttack preservationAttack = new PreservationAttack(PRESERVATION_ADDRESS);

        vm.stopBroadcast();
        return preservationAttack;
    }    
}
