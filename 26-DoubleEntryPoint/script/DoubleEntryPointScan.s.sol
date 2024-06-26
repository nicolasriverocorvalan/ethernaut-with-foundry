// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DoubleEntryPoint} from"../src/DoubleEntryPoint.sol";

contract DoubleEntryPointScan is Script {
    DoubleEntryPoint public doubleEntryPoint = DoubleEntryPoint(0xD34d38b269c9523a9329833B228a46D3b44ABD21);

    function run() external{
        vm.startBroadcast();

        address cryptoVaultAddress = doubleEntryPoint.cryptoVault();
        cryptoVaultAddress.call(abi.encodeWithSignature("underlying()"));
        address legacyTokenAddress = doubleEntryPoint.delegatedFrom();

        vm.stopBroadcast();
    }
}
