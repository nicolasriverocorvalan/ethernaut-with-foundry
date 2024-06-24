// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DoubleEntryPoint} from"../src/DoubleEntryPoint.sol";

contract RegisterBot is Script {
    DoubleEntryPoint public doubleEntryPoint = DoubleEntryPoint(0x0a6aADB6D5613F3B4aD69d98e9206e575120F16c);

    function run() external{
        vm.startBroadcast();

        doubleEntryPoint.forta().setDetectionBot(0x53d07c4967D325A6FDeEf3347D542e0B64FB14d5);

        vm.stopBroadcast();
    }
}
