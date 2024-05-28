# Gatekeeper One

Make it past the gatekeeper and register as an entrant to pass this level.

## Vulnerability

### `gateOne` 

Modifier checks if `msg.sender` is not equal to `tx.origin`.

1. `msg.sender` is a special global variable in Solidity that contains the address of the caller of the current function. If a contract function is called by another contract, `msg.sender` will be the address of that contract.

2. `tx.origin` is another special global variable in Solidity that contains the address of the original sender of the transaction. This is the `address of the externally owned account (EOA)` that initiated the transaction. If a contract function is called by another contract, `tx.origin` will still be the address of the EOA, not the contract.

### `gateTwo` 

### `gateThree`

1. `require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)))`: This condition checks if the last 4 bytes (represented by uint32) of the `_gateKey` are equal to the last 2 bytes (represented by uint16) of the `_gateKey`. This is equivalent to masking the `_gateKey` with `0x0000FFFF`.

2. `require(uint32(uint64(_gateKey)) != uint64(_gateKey))`: This condition checks if the last 4 bytes of the `_gateKey` are different from the full 8 bytes of the `_gateKey`. This means that the first 4 bytes of the `_gateKey` must not be zero, which is equivalent to masking the `_gateKey` with `0xFFFF0000FFFF`.

3. `require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)))`: This condition checks if the last 4 bytes of the `_gateKey` are equal to the last 2 bytes of the `tx.origin` (the original sender of the transaction). This is equivalent to masking the `_gateKey` with `0x0000FFFF`.

We can conclude that the key is masked with `0xFFFFFFFF0000FFFF`. This mask ensures that the first 4 bytes are not zero (due to the second condition), the last 4 bytes are equal to the last 2 bytes (due to the first and third conditions), and the middle 2 bytes can be any value.


## Attack

1. Deploy `GatekeeperOneAttack.sol`

```bash
forge script script/DeployGatekeeperOneAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x9e05EbC2fbFE3f73738aDBA0E04194dBd285c947
```
2. Attack

```bash
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

