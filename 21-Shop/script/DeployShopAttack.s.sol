// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {ShopAttack} from "../src/ShopAttack.sol";

contract DeployShopAttack is Script {
    address private constant SHOP_ADDRESS = 0x1cF71C656B9c83064CE78055539c555ea9A98825; // Shop contract

    function run() external returns (ShopAttack) {
        vm.startBroadcast();

        ShopAttack shopAttack = new ShopAttack(SHOP_ADDRESS);

        vm.stopBroadcast();
        return shopAttack;    
    }
}
