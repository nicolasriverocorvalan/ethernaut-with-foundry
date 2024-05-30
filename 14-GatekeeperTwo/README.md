# Gatekeeper Two

Register as an entrant to pass this level.

## Vulnerability

### Gate One
To ensure that `msg.sender` and `tx.origin` are different, we need to create an intermediary contract that makes function calls to the Gatekeeper contract. This setup will result in the caller's address being `tx.origin`, and the address of our deployed contract will be `msg.sender` as received by the Gatekeeper.

### Gate Two

Solidity code is using inline assembly to access the EVM opcode `extcodesize`.

`x := extcodesize(caller())`: This line is using the `extcodesize` opcode to get the size of the code at the address of the caller of the current function. The `caller()` function returns the address of the caller of the current function. The `extcodesize` opcode returns the size of the code at a given address.

This code is typically used to check if the caller of the current function is a contract or an externally owned account (EOA). Contracts have code, so `extcodesize(caller())` will return a non-zero value for contracts. EOAs do not have code, so `extcodesize(caller())` will return zero for EOAs.

If you call `extcodesize` on the address of a contract from within its constructor, it will return `0`.

This is because during the execution of the constructor, the contract is not yet fully created, and its code is not yet stored at its address. The contract's code is only stored at its address after the constructor has finished executing and the contract creation transaction is complete.

### Gate Three

`A XOR B = C` is equal to `A XOR C = B`

`require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == uint64(0) - 1);`,

This is a condition in the code that must be met for the function to continue execution. It's checking that the XOR of the 64-bit integer representation of the first 8 bytes of the `Keccak-256` hash of the sender's address and `_gateKey` is equal to the maximum possible `uint64` value.

`bytes8 key = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ ~uint64(0));`

This is the XOR of the 64-bit integer representation of the first 8 bytes of the `Keccak-256` hash of the contract's own address and the maximum possible `uint64` value. This value is calculated in such a way that, when it's used as `_gateKey` in the require statement, and the `msg.sender` is the contract's own address, the require statement will pass.

- `abi.encodePacked(address(this))` encodes the contract's own address.
- `keccak256(...)` computes the `Keccak-256` hash of the encoded address.
- `bytes8(...)` takes the first 8 bytes of the hash.
- `uint64(...)` interprets these 8 bytes as a 64-bit unsigned integer.
- `... ^ (uint64(0) - 1)` performs a bitwise `XOR` operation between the integer and `uint64(0) - 1`. Since `uint64(0) - 1` underflows to `type(uint64).max`, this effectively inverts all the bits of the integer.

This results in a `bytes8` value that, when XORed with the `uint64` representation of the first `8` bytes of the `Keccak-256` hash of the sender's address, should equal `type(uint64).max`, as required by the require statement.

So if `Key` is used as `_gateKey` in the require statement, and the `msg.sender` is the contract's own address, the require statement should pass.

1. Deploy `GatekeeperTwoAttack.sol` and Attack.

```bash
forge script script/DeployGatekeeperTwoAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0xE142D54936f018291F3973038b5f4b4743bcC9c0

## Fix

The entire contract must be refactored.
