// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IForta {
    function raiseAlert(address user) external;
}

contract FortaBot {
    address private cryptoVault;

    constructor(address _cryptoVault) {
        cryptoVault = _cryptoVault;
    }

    function handleTransaction(address user, bytes calldata msgData) external {
        // Extract the address of original message sender
        // which should start at offset 168 (0xa8) of calldata
        address origSender;
        assembly {
            origSender := calldataload(0xa8)
        }

        if (origSender == cryptoVault) {
            IForta(msg.sender).raiseAlert(user);
        }
    }
}
