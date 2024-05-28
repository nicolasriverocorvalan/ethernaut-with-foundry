// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {GatekeeperOneAttack} from "../src/GatekeeperOneAttack.sol";

contract DeployGatekeeperOneAttack is Script {
    address private constant GATEKEEEPER_ONE_ADDRESS = 0x4fB22C2e1b79c9bDCfd828C8A59476C673EA9869; //Gatekeeper One contract to attack

    function run() external returns (GatekeeperOneAttack) {
        vm.startBroadcast();

        GatekeeperOneAttack gatekeeperOneAttack = new GatekeeperOneAttack(GATEKEEEPER_ONE_ADDRESS);

        vm.stopBroadcast();
        return gatekeeperOneAttack;
    }    
}
