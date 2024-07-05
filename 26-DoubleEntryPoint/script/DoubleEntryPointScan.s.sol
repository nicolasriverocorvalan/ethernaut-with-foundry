// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DoubleEntryPoint} from"../src/DoubleEntryPoint.sol";

contract DoubleEntryPointScan is Script {
    DoubleEntryPoint public doubleEntryPoint = DoubleEntryPoint(0x055b8Ca8dd26e6932E24dB7F9c2e0569faAE770C);

    function run() external{
        vm.startBroadcast();

        address cryptoVaultAddress = doubleEntryPoint.cryptoVault();
        cryptoVaultAddress.call(abi.encodeWithSignature("underlying()"));
        address legacyTokenAddress = doubleEntryPoint.delegatedFrom();

        vm.stopBroadcast();
    }
}
