# Force

Make the balance of the contract greater than zero.

## Notes

```
`selfdestruct` has been deprecated. Note that, starting from the `Cancun` hard fork, the opcode no longer deletes the code and data associated with an account and only transfers its Ether to the beneficiary, unless executed in the same transaction in which the contract was created (see EIP-6780). Any use in newly deployed contracts is strongly discouraged even if the new behavior is taken into account. Future changes to the EVM might further reduce the functionality of the opcode.
````

In Ethereum, you can send Ether to a contract in two ways:

1. By calling a payable function in the contract.
2. By sending Ether to the contract's address.

The `Force` contract doesn't have any functions. So, the only way to increase its balance is by sending Ether directly to the contract's address.

## Found

1. Deploy `TelephoneAttack.sol` using the cast deploy command.

```bash
forge script script/DeployFoundForce.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0xD6C3f00f2edCd960e69AC53194b49C6A9A06c5b5
```

2. Found

```bash
cast send $CONTRACT_ADDRESS "found()" --value 1wei  --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```
