// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Dex2AttackToken} from "../src/Dex2AttackToken.sol";

contract DeployDex2AttackToken is Script {
    function run() external returns (Dex2AttackToken) {
        vm.startBroadcast();

        Dex2AttackToken dex2AttackToken = new Dex2AttackToken(400);

        vm.stopBroadcast();
        return dex2AttackToken;
    }    
}
