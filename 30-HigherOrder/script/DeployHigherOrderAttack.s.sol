// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "forge-std/Script.sol";
import {HigherOrderAttack} from"../src/HigherOrderAttack.sol";

contract DeploySwitchAttack is Script {
    address public constant higherOrderAddress = 0x91dd65eb6Bc362acaaFceE1F271504Bd0Da992AD;
    HigherOrderAttack public higherOrderAttack;

    function run() external{
        vm.startBroadcast();

        higherOrderAttack = new HigherOrderAttack(higherOrderAddress);
        
        vm.stopBroadcast();
    }
}
