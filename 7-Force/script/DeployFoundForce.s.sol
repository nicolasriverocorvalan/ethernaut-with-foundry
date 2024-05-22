// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {FoundForce} from "../src/FoundForce.sol";

contract DeployFoundForce is Script {
    address payable private constant FORCE_ADDRESS = payable(0x7a3Ce363EA6C5fa896cE3eec4b9c27282980e448); //Force contract to attack

    function run() external returns (FoundForce) {
        vm.startBroadcast();

        FoundForce foundForce = new FoundForce(FORCE_ADDRESS);

        vm.stopBroadcast();
        return foundForce;
    }
}
