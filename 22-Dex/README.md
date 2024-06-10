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

| Dex  |      | User |      |
|------|------|------|------|
|token1|token2|token1|token2|
| 100  | 100  | 10   | 10   |
| 110  | 90   | 0    | 20   |
| 86   | 110  | 24   | 0    |
| 110  | 80   | 0    | 30   |
| 69   | 110  | 41   | 0    |
| 110  | 45   | 0    | 65   |
| 0    | 90   | 110  | 20   |

```bash
$ python3.11 DexAttack.py

# https://sepolia.etherscan.io/address/0x31f19CDb0FD6801A8A0CCf7B1D3e09208b5674Fd
```

## Fix

1. Use a more precise arithmetic library or implement your own that can handle large numbers and fractional values without rounding down. This could be a library like `Decimal` in Python or `BigDecimal` in Java.

2. Instead of directly using the balances of token1 and token2 to calculate the swap rate, use a price oracle or some other external, reliable source of pricing information to determine the correct swap rate.

3. Implement checks to ensure that the User cannot drain the Dex's tokens. This could be a maximum limit on the size of a single swap or a check that the Dex's balance of a token cannot go below a certain threshold.

4. Consider implementing a `slippage` protection mechanism. This would allow users to specify a maximum acceptable `slippage (price change)` for their swap. If the actual slippage exceeds this amount, the transaction would be reverted.
