// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {GatekeeperThreeAttack} from"../src/GatekeeperThreeAttack.sol";

contract DeployGatekeeperThreeAttack is Script {
    address public constant gatekeeperThreeAddress = 0xcDf5BF83835dD99a5C824B5c597751AfDbD8e234;
    GatekeeperThreeAttack public gatekeeperThreeAttack;

    function run() external{
        vm.startBroadcast();

        gatekeeperThreeAttack = new GatekeeperThreeAttack(gatekeeperThreeAddress);
        
        vm.stopBroadcast();
    }
}
