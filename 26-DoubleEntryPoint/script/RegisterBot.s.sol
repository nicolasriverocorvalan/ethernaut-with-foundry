// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DoubleEntryPoint} from"../src/DoubleEntryPoint.sol";

contract RegisterBot is Script {
    DoubleEntryPoint public doubleEntryPoint = DoubleEntryPoint(0xD34d38b269c9523a9329833B228a46D3b44ABD21);

    function run() external{
        vm.startBroadcast();

        doubleEntryPoint.forta().setDetectionBot(0x6a317a83402C20B1175DBE76b8006BFEbC10Cf26);

        vm.stopBroadcast();
    }
}
