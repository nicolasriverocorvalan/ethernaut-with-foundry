// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract FoundForce {
    address payable private forceAddress;

    constructor(address payable _forceAddress) {
        forceAddress = _forceAddress;
    }

    function found() external payable {
        selfdestruct(forceAddress);
    }
}
