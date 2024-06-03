// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {PreservationAttack} from "../src/PreservationAttack.sol";

contract DeployPreservationAttack is Script {
    address private constant PRESERVATION_ADDRESS = 0x5E1429084cdf0446d575b1DE68C649Bc8aA7Bd26; // Preservation contract to attack

    function run() external returns (PreservationAttack) {
        vm.startBroadcast();

        PreservationAttack preservationAttack = new PreservationAttack(PRESERVATION_ADDRESS);

        vm.stopBroadcast();
        return preservationAttack;
    }    
}
