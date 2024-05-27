// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {GatekeeperOneAttack} from "../src/GatekeeperOneAttack.sol";

contract DeployGatekeeperOneAttack is Script {
    address private constant GATEKEEEPER_ONE_ADDRESS = 0xdfDdeaC38D65688eB0979f8B52c09Db7529c6Ce6; //Gatekeeper One contract to attack

    function run() external returns (GatekeeperOneAttack) {
        vm.startBroadcast();

        GatekeeperOneAttack gatekeeperOneAttack = new ElevatorAttack(GATEKEEEPER_ONE_ADDRESS);

        vm.stopBroadcast();
        return gatekeeperOneAttack;
    }    
}
