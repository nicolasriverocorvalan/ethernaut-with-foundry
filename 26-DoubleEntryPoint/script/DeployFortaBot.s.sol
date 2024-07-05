// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DoubleEntryPoint} from"../src/DoubleEntryPoint.sol";
import {FortaBot} from"../src/FortaBot.sol";

contract RegisterBot is Script {
    DoubleEntryPoint public doubleEntryPoint = DoubleEntryPoint(0x055b8Ca8dd26e6932E24dB7F9c2e0569faAE770C);
    FortaBot public fortaBot;
    address public vaultAddress = 0xFAf657dB02Db174eB45eC8A0f5C8C45E0F1c9760;

    function run() external{
        vm.startBroadcast();

        fortaBot = new FortaBot(vaultAddress);
        doubleEntryPoint.forta().setDetectionBot(address(fortaBot));

        vm.stopBroadcast();
    }
}
