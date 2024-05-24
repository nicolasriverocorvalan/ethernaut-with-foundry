// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {KingAttack} from "../src/KingAttack.sol";

contract DeployKingAttack is Script {
    address private constant KING_ADDRESS = 0x1A7D71832AD7F5D7Dd3797069612170eaCb99230; //King contract to attack

    function run() external returns (KingAttack) {
        vm.startBroadcast();

        KingAttack kingAttack = new KingAttack(payable(KING_ADDRESS));

        vm.stopBroadcast();
        return kingAttack;
    }
}
