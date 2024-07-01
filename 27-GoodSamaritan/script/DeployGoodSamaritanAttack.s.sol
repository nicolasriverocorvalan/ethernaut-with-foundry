// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import {GoodSamaritanAttack} from"../src/GoodSamaritanAttack.sol";

contract DeployGoodSamaritanAttack is Script {
    GoodSamaritanAttack public goodSamaritanAttack;

    function run() external{
        vm.startBroadcast();

        goodSamaritanAttack = new GoodSamaritanAttack();
        
        vm.stopBroadcast();
    }
}
