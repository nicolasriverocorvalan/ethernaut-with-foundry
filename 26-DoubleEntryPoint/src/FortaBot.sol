// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

interface IForta {
    function raiseAlert(address user) external;
    function setDetectionBot(address detectionBotAddress) external;
    function notify(address user, bytes calldata msgData) external;
}

contract FortaBot is IDetectionBot {
    address private cryptoVault;

    constructor(address _cryptoVault) {
        cryptoVault = _cryptoVault;
    }

    function handleTransaction(address user, bytes calldata msgData) external override {
        // Extract the origSender from msgData.
        address origSender;

        // origSender is encoded in a specific position in msgData, extract it.
        assembly {
            origSender := calldataload(0xa8)
        }

        if(origSender == cryptoVault) {
            // If the origSender is the cryptoVault, raise an alert
            IForta(msg.sender).raiseAlert(user);
        }
    }
}
