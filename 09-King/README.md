# King

Whoever sends an amount of ether larger than the current prize becomes the new king. When this happens, the overthrown king receives the new prize, earning some ether in the process. This mechanism is as Ponzi-like as it gets.

The goal is to break this system. When you submit the instance back to the level, the level will attempt to reclaim kingship. You will beat the level if you can prevent such self-proclamation.

## Vulnerability

### Reentrancy Attack

The receive() function first sends Ether to the current king and then updates the king to the sender. This could potentially allow for a reentrancy attack if the current king's fallback function calls back into the receive() function.

### Denial of Service (DoS) Attack

If the current king is a contract that has a fallback function which fails, it could prevent anyone else from becoming the king because the transfer function will always fail. This is a type of DoS attack. To mitigate this, you could use the call function instead of transfer and handle failed sends appropriately.

### Force Sending Ether

It's possible to forcibly send Ether to a contract without calling its receive or fallback function. This means someone could become the king without following the rules of the game.

### Ownership

The receive() function allows the owner to become the king without sending any Ether. This could be considered unfair if this is meant to be a fair game.

## Attack

1. Deploy `KingAttack.sol`

```bash
forge script script/DeployKingAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0xcc38deD39Fa3fA8ACaE26609BA1b044f53B44924
```
2. Attack

```bash
cast send $CONTRACT_ADDRESS "becomeKing()" --value 1000000000000000wei --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

### Reentrancy Attack

You should follow the `Checks-Effects-Interactions` pattern, which means you should update the state variables before transferring Ether.

### Denial of Service (DoS) Attack

You could use the call function instead of transfer and handle failed sends appropriately.

### Force Sending Ether

You could check the contract balance against the prize variable and revert if they don't match.

### Ownership

Remove the exception for the owner.
