# Naught Coin

NaughtCoin is an ERC20 token and you're already holding all of them. The catch is that you'll only be able to transfer them after a 10 year lockout period. Can you figure out how to get them out to another address so that you can transfer them freely? Complete this level by getting your token balance to 0.

[ERC20 Spec](https://github.com/ethereum/ercs/blob/master/ERCS/erc-20.md)

[OpenZeppelin contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts)

## Vulnerability

### ERC20 `approve` function

The `approve` function is part of the ERC20 token standard in Ethereum. It allows a token holder to approve another address (often referred to as the `spender`) to withdraw tokens from the token holder's account.

`function approve(address spender, uint256 amount) public returns (bool);`

- `spender`: The address which will be allowed to spend the tokens.
- `amount`: The number of tokens that the spender will be allowed to withdraw from the token holder's account.

The function returns a boolean value indicating whether the operation was successful. 

Once the `approve` function is called, the spender can use the `transferFrom` function to move up to the approved number of tokens from the token holder's account to another account. The spender can do this until the approved amount is exhausted or until the token holder revokes the approval by calling `approve` again with an amount of `0`.

It's important to note that there is a known race condition in the `approve` function: if a token holder calls `approve` to change the approved amount while the spender is in the process of using `transferFrom`, it's possible for the spender to use more than the token holder intended. To avoid this, token holders should generally revoke approval (by calling `approve` with an amount of `0`) before setting a new approved amount.

### ERC20 `transferFrom` function

The `transferFrom` allows a third-party (often referred to as the "spender") to transfer tokens from one account to another, provided that the token owner has approved the spender to do so using the approve function.

`function transferFrom(address sender, address recipient, uint256 amount) public returns (bool);`

- `sender`: The address from which the tokens will be transferred.
- `recipient`: The address to which the tokens will be transferred.
- `amount`: The number of tokens to be transferred.

The function returns a boolean value indicating whether the operation was successful.

Before `transferFrom` can be called, the token owner must first call the `approve` function to set an allowance for the spender. The `transferFrom` function then transfers tokens from the owner's account to the recipient, and reduces the allowance by the same amount.

If the spender tries to transfer more tokens than the allowance, or more tokens than the owner has, the `transferFrom` function will fail and return `false`.

It's important to note that the `approve` and `transferFrom` functions can potentially be vulnerable to a race condition known as the `ERC20 approve front-running attack"`. To avoid this, some token contracts implement an additional function, often called `increaseAllowance`, to safely increase the allowance without first having to reduce it to 0.

Since the `NaughtCoin.sol` contract inherits from ERC20 and `lockTokens()` modifier does not enforce `timelock` on the `transferFrom()` function, we can call `approve` and `transferFrom` to transfer all the tokens out of our account.

## Attack

1. Deploy `GatekeeperTwoAttack.sol`.

```bash
forge script script/DeployNaughtCoinAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x6979CC6F710D8218872dB97a9c9Bcbc6460Bc7e1
```

2. Attack

```bash
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix


