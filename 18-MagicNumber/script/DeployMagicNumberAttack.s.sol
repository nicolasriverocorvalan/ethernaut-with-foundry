// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MagicNum} from "../src/MagicNumber.sol";

contract DeployMagicNumberAttack is Script {
    address private constant MAGIC_NUMBER = 0xCf334C1712Ce49540663D26424F897e54D7ca2dC; // Magic Number contract

    function run() external {
        vm.startBroadcast();

        MagicNum magicNum = MagicNum(MAGIC_NUMBER);
        bytes memory code = "\x60\x0a\x60\x0c\x60\x00\x39\x60\x0a\x60\x00\xf3\x60\x2a\x60\x80\x52\x60\x20\x60\x80\xf3";
        address solver;

        assembly {
            solver := create(0, add(code, 0x20), mload(code))
        }
        
        magicNum.setSolver(solver);
        vm.stopBroadcast();
    }  
}
