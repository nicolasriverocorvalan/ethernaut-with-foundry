# Gatekeeper One

Make it past the gatekeeper and register as an entrant to pass this level.

## Vulnerability

### Gate One
To ensure that `msg.sender` and `tx.origin` are different, we need to create an intermediary contract that makes function calls to the Gatekeeper contract. This setup will result in the caller's address being `tx.origin`, and the address of our deployed contract will be `msg.sender` as received by the Gatekeeper.

### Gate Three

- `Downcasting` in Solidity is the process of converting a larger integer type to a smaller integer type. For example, converting a uint16 to a uint8. This operation can potentially lead to data loss if the value of the larger integer type doesn't fit into the smaller integer type. Therefore, explicit conversion is required in Solidity.

- `Bitmasking` is a technique in programming to select specific bits from a number. It involves bitwise operations, particularly the bitwise AND (&), OR (|), XOR (^), and NOT (~) operations. In Solidity, you can use `bitmasking` to manipulate bits in integer types. For example, you can use a mask to select the last 4 bytes of a bytes8 value:

```bash
bytes8 value = 0x1234567890abcdef;
bytes8 mask = 0x00000000ffffffff;
bytes8 last4Bytes = value & mask;  // Bitmasking
```
In this example, `value & mask` performs a bitwise AND operation between `value` and `mask`. The result is a `bytes8` value where only the last 4 bytes of value are kept, and the rest are set to zero.

To bypass gate3, Let's assume that we have to send the following value as our key `0x A1 A2 A3 A4 A5 A6 A7 A8` (`bytes8 _gateKey`).

```bash
modifier gateThree(bytes8 _gateKey) {
    require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
    require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
    require(uint32(uint64(_gateKey)) == uint16(tx.origin), "GatekeeperOne: invalid gateThree part three");
    _;
}
```

1. The first statement satisfy the following condition:

`0x A5 A6 A7 A8 == 0x 00 00 A7 A8`

2. The second statement satisfy the following condition:

`0x 00 00 00 00 A5 A6 A7 A8 != 0x A1 A2 A3 A4 A5 A6 A7 A8`

3. The third statement satisfy the following condition:

`0x A5 A6 A7 A8 == 0x 00 00 (last two bytes of tx.origin)`

4. The key will be:

|          |    A1    |    A2    |    A3    |    A4    |    A5    |    A6    |              A7              |           A8          |
|----------|----------|----------|----------|----------|----------|----------|------------------------------|-----------------------|
|    Ox    |   ANY    |   ANY    |   ANY    |    ANY   |    00    |    00    |    SECOND_LAST_BYTE_OF_TX    |    LAST_BYTE_OF_TX    |     


So we can use the `AND` operation to set the value of `A5` and `A6` to 0, and the last two bytes (`FFFF`) to our `tx.origin`'s last two bytes.

### Gate Two

The `gasleft()` function in Solidity returns the remaining gas that can be used in the current transaction. To clear gate two, we need to ensure that `gasleft() % 8191 == 0`, i.e., our supplied gas input should be a multiple of 8191. Could be brute-forced.

## Attack

1. Deploy `GatekeeperOneAttack.sol`

```bash
forge script script/DeployGatekeeperOneAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x9F94242F288f7F7b6B33Bc357792883d03448c17

2. Attack

```bash
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

The entire contract must be refactored.
