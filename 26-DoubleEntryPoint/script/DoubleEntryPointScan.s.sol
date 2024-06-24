// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DoubleEntryPoint} from"../src/DoubleEntryPoint.sol";

contract DoubleEntryPointScan is Script {
    DoubleEntryPoint public doubleEntryPoint = DoubleEntryPoint(0x0a6aADB6D5613F3B4aD69d98e9206e575120F16c);

    function run() external{
        vm.startBroadcast();

        address cryptoVaultAddress = doubleEntryPoint.cryptoVault();
        cryptoVaultAddress.call(abi.encodeWithSignature("underlying()"));
        address legacyTokenAddress = doubleEntryPoint.delegatedFrom();

        vm.stopBroadcast();
    }
}
