# Recovery

A contract creator has developed a simple token factory contract that allows anyone to easily create new tokens. After deploying the first token contract, the creator sent 0.001 ether to it. However, they have since lost the address of this first token contract.

To complete this challenge, you need to recover or remove the 0.001 ether from the lost contract address.

## Vulnerability

## Attack

1. Deploy `RecoveryAttack.sol`

```bash
forge script script/DeployRecoveryAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x6f5c067b429652Bfa30e06227307f17eAdEfc76A

2. Attack

```bash
cast send $CONTRACT_ADDRESS "computeAddress()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy

cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

