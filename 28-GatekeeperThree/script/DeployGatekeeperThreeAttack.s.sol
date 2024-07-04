// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {GatekeeperThreeAttack} from"../src/GatekeeperThreeAttack.sol";

contract DeployGatekeeperThreeAttack is Script {
    address public constant gatekeeperThreeAddress = 0x6757e61D0dd5099409AD5054024c2895efE88fD6;
    GatekeeperThreeAttack public gatekeeperThreeAttack;

    function run() external{
        vm.startBroadcast();

        gatekeeperThreeAttack = new GatekeeperThreeAttack(gatekeeperThreeAddress);
        
        vm.stopBroadcast();
    }
}
