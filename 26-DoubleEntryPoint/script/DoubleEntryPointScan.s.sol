// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DoubleEntryPoint} from"../src/DoubleEntryPoint.sol";

contract DoubleEntryPointScan is Script {
    DoubleEntryPoint public doubleEntryPoint = DoubleEntryPoint(0x9fC00a7f729AC7B226b7F626Db04E4280F264de7);

    function run() external{
        vm.startBroadcast();

        address cryptoVaultAddress = doubleEntryPoint.cryptoVault();
        cryptoVaultAddress.call(abi.encodeWithSignature("underlying()"));
        address legacyTokenAddress = doubleEntryPoint.delegatedFrom();

        vm.stopBroadcast();
    }
}
