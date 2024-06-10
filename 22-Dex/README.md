# Dex

The goal of this level is for you to hack the basic DEX contract and steal the funds by price manipulation.

You will start with 10 tokens of `token1` and 10 of `token2`. The DEX contract starts with 100 of each token.

You will be successful in this level if you manage to drain all of at least 1 of the 2 tokens from the contract, and allow the contract to report a `bad` price of the assets.

## Quick Note

Normally, when you make a swap with an ERC20 token, you have to `approve` the contract to spend your tokens for you. To keep with the syntax of the game, we've just added the `approve` method to the contract itself. So feel free to use `contract.approve(contract.address, <uint amount>)` instead of calling the tokens directly, and it will automatically approve spending the two tokens by the desired amount. Feel free to ignore the `SwappableToken` contract otherwise.

## Vulnerability

```bash
function getSwapPrice(address from, address to, uint256 amount) public view returns (uint256) {
    return ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
}
```

1. `IERC20(token2).balanceOf(address(this))`: this is getting the balance of the to `token2` that the contract owns.

2. `IERC20(token1).balanceOf(address(this)`): this is getting the balance of the from `token1` that the contract owns.

3. `amount * IERC20(token2).balanceOf(address(this))`: this is calculating the total to `tokens2` that would be equivalent to the amount of `token1`, based on the current balance ratio of `token2` and `token1` tokens in the contract.

4. `((amount * IERC20(token2).balanceOf(address(this))) / IERC20(token1).balanceOf(address(this)))`: this is dividing the total to tokens by the balance of from tokens in the contract, to get the final swap price.

This is implementing a simple `constant product market maker model`, where the product of the quantities of the two tokens remains constant.

### Integer Division

If `amount * IERC20(token2).balanceOf(address(this))` is not a multiple of `IERC20(token1).balanceOf(address(this))`, the division will be rounded down, which could lead to imprecise calculations.

## Attack

```bash
$ python3.11 DexAttack.py
```


## Fix
