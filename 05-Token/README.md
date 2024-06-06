# Token

You are given 20 tokens to start with and you will beat the level if you somehow manage to get your hands on any additional tokens. Preferably a very large amount of tokens.

## Vulnerability

The `transfer` function (`pragma solidity ^0.6.0`) in your contract has a vulnerability related to underflow. Solidity uses unsigned integers, which means they can't be negative. If `_value` is greater than balances[msg.sender], the subtraction will underflow and result in a very large number, not a negative number. This would pass your require statement and could lead to unexpected behavior.

The attacker calls the transfer function with a `_value` greater than their current balance. For example, with a zero balance address, the attacker could call transfer with `_value` set to `n` tokens to any address.

## Attack

```bash
cast send $CONTRACT_ADDRESS "transfer(address,uint256)" $ACCOUNT_ADDRESS 100 --private-key $PRIVATE_KEY_ACCOUNT_2 --rpc-url $ALCHEMY_RPC_URL --legacy
```
Note: `PRIVATE_KEY_ACCOUNT_2` -> initial balance = 0 tokens

## Fix

To fix this vulnerability, you should check if `balances[msg.sender]` is greater than or equal to `_value` before subtracting `_value`:

```bash
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
balances[_to] += _value;
```
