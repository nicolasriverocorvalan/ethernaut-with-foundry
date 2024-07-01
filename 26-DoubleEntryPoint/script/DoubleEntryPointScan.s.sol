// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DoubleEntryPoint} from"../src/DoubleEntryPoint.sol";

contract DoubleEntryPointScan is Script {
    DoubleEntryPoint public doubleEntryPoint = DoubleEntryPoint(0x09EB1387490f88C413D80914cfdc9B94255729e8);

    function run() external{
        vm.startBroadcast();

        address cryptoVaultAddress = doubleEntryPoint.cryptoVault();
        cryptoVaultAddress.call(abi.encodeWithSignature("underlying()"));
        address legacyTokenAddress = doubleEntryPoint.delegatedFrom();

        vm.stopBroadcast();
    }
}
