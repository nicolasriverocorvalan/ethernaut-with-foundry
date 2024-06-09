# Shop

Сan you get the item from the shop for less than the price asked?



## Vulnerability

`Shop.sol` contract is vulnerable to a `front-running attack` because it doesn't check who the `buyer` is in the `buy()` function. An attacker can create a contract that implements the `Buyer` interface and sets the price to a high value when the `price()` function is called, but then changes the price to a lower value when actually transferring the funds.

## Attack

In the attack contract, the `price()` function initially returns the price of the item in the shop. However, when the `buy()` function in the `Shop` contract sends funds to the `ShopAttack` contract, the `receive()` function is triggered, which sets the price to 1. This allows the attacker to buy the item for less than the asked price.


## Fix

```bash
pragma solidity ^0.8.0;

contract Shop {
    uint256 public price = 100;
    bool public isSold;

    function buy() public payable {
        require(msg.value >= price, "Not enough Ether provided.");
        require(!isSold, "Item has already been sold.");

        isSold = true;
    }
}
```

In this version of the `buy()` function, we use the `msg.value` keyword to access the amount of Ether sent with the function call. We then use the `require()` function to ensure that this amount is at least equal to the price of the item. This way, we ensure that the buyer always pays at least the asked price, regardless of what the `price()` function of the `Buyer` contract returns.
