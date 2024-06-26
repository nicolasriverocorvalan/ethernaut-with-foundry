// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DoubleEntryPoint} from"../src/DoubleEntryPoint.sol";

contract RegisterBot is Script {
    DoubleEntryPoint public doubleEntryPoint = DoubleEntryPoint(0x9fC00a7f729AC7B226b7F626Db04E4280F264de7);

    function run() external{
        vm.startBroadcast();

        doubleEntryPoint.forta().setDetectionBot(0x0CA7964911b3F29Cdba8C74853af729701A1Db63);

        vm.stopBroadcast();
    }
}
