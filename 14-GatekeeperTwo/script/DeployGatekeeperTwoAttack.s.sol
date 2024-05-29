// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {GatekeeperTwoAttack} from "../src/GatekeeperTwoAttack.sol";

contract DeployGatekeeperTwoAttack is Script {
    address private constant GATEKEEEPER_TWO_ADDRESS = 0x10028891182884A2F753B90451a06bAF4B8Cb241; //Gatekeeper Two contract to attack

    function run() external returns (GatekeeperTwoAttack) {
        vm.startBroadcast();

        GatekeeperTwoAttack gatekeeperTwoAttack = new GatekeeperTwoAttack(GATEKEEEPER_TWO_ADDRESS);

        vm.stopBroadcast();
        return gatekeeperTwoAttack;
    }    
}
