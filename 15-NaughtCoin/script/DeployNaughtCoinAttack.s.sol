// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {NaughtCoinAttack} from "../src/NaughtCoinAttack.sol";

contract DeployNaughtCoinAttack is Script {
    address private constant NAUGHTCOIN_ADDRESS = 0x4dfb320D99C81456C5aAc22ceF1e51724eA0EcaF; // Naught Coin contract to attack

    function run() external returns (NaughtCoinAttack) {
        vm.startBroadcast();

        NaughtCoinAttack naughtCoinAttack = new NaughtCoinAttack(NAUGHTCOIN_ADDRESS);

        vm.stopBroadcast();
        return naughtCoinAttack;
    }    
}
