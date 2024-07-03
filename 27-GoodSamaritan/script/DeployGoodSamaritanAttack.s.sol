// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import {GoodSamaritanAttack} from"../src/GoodSamaritanAttack.sol";

contract DeployGoodSamaritanAttack is Script {
    address public constant goodSamaritanAddress = 0xC43d9131925d5D122E189f659911539083FF0DAC;
    GoodSamaritanAttack public goodSamaritanAttack;

    function run() external{
        vm.startBroadcast();

        goodSamaritanAttack = new GoodSamaritanAttack(goodSamaritanAddress);
        
        vm.stopBroadcast();
    }
}
