// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {StakeAttack} from"../src/StakeAttack.sol";

contract DeployStakeAttack is Script {
    address public constant stakeAddress = 0x07C02666f37ac5E5F5247CA6265641d0a6d10A1a;
    StakeAttack public stakeAttack;
    address public wethAddress = 0xCd8AF4A0F29cF7966C051542905F66F5dca9052f;

    function run() external{
        vm.startBroadcast();

        stakeAttack = new StakeAttack(stakeAddress, wethAddress);
        
        vm.stopBroadcast();
    }
}
