// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DoubleEntryPoint} from"../src/DoubleEntryPoint.sol";
import {FortaBot} from"../src/FortaBot.sol";

contract RegisterBot is Script {
    DoubleEntryPoint public doubleEntryPoint = DoubleEntryPoint(0xd2ed0d4BcB72DaD1f452a1Fb865EE326c27AD865);
    FortaBot public fortaBot;
    address public vaultAddress = 0xae598C7e5B4e6758c299763954764781F1A02361;

    function run() external{
        vm.startBroadcast();

        fortaBot = new FortaBot(vaultAddress);
        doubleEntryPoint.forta().setDetectionBot(address(fortaBot));

        vm.stopBroadcast();
    }
}
