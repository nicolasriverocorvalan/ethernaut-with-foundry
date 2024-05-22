// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {CoinFlipAttack} from "../src/CoinFlipAttack.sol";

contract DeployCoinFlipAttack is Script {
    address private constant COINFLIP_ADDRESS = 0x1728d719BD15219539b8205DE86B0B2C54b5D9Aa; //CoinFlip contract to attack

    function run() external returns (CoinFlipAttack) {
        vm.startBroadcast();

        CoinFlipAttack coinFlipAttack = new CoinFlipAttack(COINFLIP_ADDRESS);

        vm.stopBroadcast();
        return coinFlipAttack;
    }
}
