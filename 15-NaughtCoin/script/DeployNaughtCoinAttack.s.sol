// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {NaughtCoinAttack} from "../src/NaughtCoinAttack.sol";

contract DeployNaughtCoinAttack is Script {
    address private constant NAUGHTCOIN_ADDRESS = 0xfAa0972485478799744bbaAE96e77fA63d95864A; // Naught Coin contract to attack

    function run() external returns (NaughtCoinAttack) {
        vm.startBroadcast();

        NaughtCoinAttack naughtCoinAttack = new NaughtCoinAttack(NAUGHTCOIN_ADDRESS);

        vm.stopBroadcast();
        return naughtCoinAttack;
    }    
}
