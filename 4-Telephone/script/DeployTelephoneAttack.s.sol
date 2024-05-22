// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {TelephoneAttack} from "../src/TelephoneAttack.sol";

contract DeployCoinFlipAttack is Script {
    address private constant TELEPHONE_ADDRESS = 0xFB9BF27079B6cc3e2356d4B734852BEFD882B766; //Telephone contract to attack

    function run() external returns (TelephoneAttack) {
        vm.startBroadcast();

        TelephoneAttack telephoneAttack = new TelephoneAttack(TELEPHONE_ADDRESS);

        vm.stopBroadcast();
        return telephoneAttack;
    }
}
