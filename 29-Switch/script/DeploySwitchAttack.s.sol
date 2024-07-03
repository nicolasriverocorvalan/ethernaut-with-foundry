// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {SwitchAttack} from"../src/SwitchAttack.sol";

contract DeploySwitchAttack is Script {
    address public constant switchAddress = 0xC719Cd5ba83aD27F62c557e3492b4879B8C394FF;
    SwitchAttack public switchAttack;

    function run() external{
        vm.startBroadcast();

        switchAttack = new SwitchAttack(switchAddress);
        
        vm.stopBroadcast();
    }
}
