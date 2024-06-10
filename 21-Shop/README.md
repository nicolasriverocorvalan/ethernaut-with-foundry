# Shop

Сan you get the item from the shop for less than the price asked?


## Vulnerability

In Solidity, `external` and `view` are function visibility specifiers.

* `external`: means that the function can only be called from outside the contract. It cannot be called internally, except with this.functionName(). External functions can be more gas-efficient when they receive large arrays as input, because the data is not copied to memory but read directly from `calldata`.

* `view`: This indicates that the function will not modify the state of the contract. In other words, it won't change any values or write anything on the blockchain. It only reads the state and returns a value based on it. This is useful for functions that return the value of a variable or compute and return some value from the contract's state.

If the `buy()` function in the `Shop.sol` contract doesn't check who the buyer is, it could indeed be vulnerable to an attack where an attacker creates a contract that implements the `Buyer` interface and manipulates the `price()` function.

## Attack

1. Deploy `ShopAttack.sol`

```bash
forge script script/DeployShopAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x6c88D785FE367d66B390C461Ec7C76EB53cd0BDf

2. Attack

```bash
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```


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
