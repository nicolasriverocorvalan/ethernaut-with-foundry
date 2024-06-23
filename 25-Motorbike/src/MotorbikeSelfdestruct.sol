// SPDX-License-Identifier: MIT

pragma solidity <0.7.0;

contract MotorbikeSelfdestruct {
    function destruct() external {
        selfdestruct(address(0));
    }
}
