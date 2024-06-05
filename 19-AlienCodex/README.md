# Alien Codex

You've uncovered an Alien contract. Claim ownership to complete the level.

[ABI specifications](https://docs.soliditylang.org/en/v0.4.21/abi-spec.html)

## Vulnerability

In Ethereum smart contracts, storage is a key-value store that maps 256-bit words to 256-bit words. The first state variable that you declare in a contract is stored in slot 0, the second one in slot 1, and so on.

In the `AlienCodex` contract, the `owner` variable is inherited from the `Ownable` contract and is therefore not the first state variable declared. This means it's not stored in slot 0, but in a later slot.

1. `make_contact()` Function
Call the `make_contact()` function so that the `contact` variable is set to `true`. This will allow us to bypass the `contacted()` modifier.

2. `retract()` Function
Call the `retract()` function. This will decrease the `codex.length` by 1. When you subtract 1 from 0 (the initial array position), you get an underflow. This will allow us to access any storage slot in the contract.

3. `revise()` Function
Call the `revise()` function to access the array at slot 0 and update the `owner`'s value with our own address.

### Codex array index breakdown

```bash
uint index = ((2 ** 256) - 1) - uint(keccak256(abi.encode(1))) + 1;
```

1. `2 ** 256` calculates 2 to the power of 256. This is the maximum value a 256-bit unsigned integer (`uint`) can hold in Solidity.

2. `(2 ** 256) - 1` subtracts one from the maximum `uint` value. This results in a `uint` with all bits set to 1, which is the maximum possible value for a `uint` in Solidity.

3. `abi.encode(1)` encodes the number 1 as per the Ethereum ABI specification. This is used as input to the `keccak256` function.

4. `keccak256(abi.encode(1))` computes the Keccak-256 hash of the encoded number 1. This results in a 32-byte hash, which is then converted to a `uint`.

5. `((2 ** 256) - 1) - uint(keccak256(abi.encode(1)))` subtracts the `uint` value of the hash from the maximum `uint` value. This is used to create a pseudo-random number, in this context, it's used to calculate the storage slot of the `owner` variable.

6. `((2 ** 256) - 1) - uint(keccak256(abi.encode(1))) + 1` finally, it adds 1 to the result. The purpose of this is to ensure that the result is never zero, because storage `slot 0` is reserved for the `contact` variable.

So, the index variable will hold the storage slot of the `owner` variable. This is used in the `revise()` function to overwrite the `owner` variable with the address of the attacker, effectively transferring ownership of the contract to the attacker.

```bash
function revise(uint256 i, bytes32 _content) public contacted {
    codex[i] = _content;
}
```

The `_content` is of type `bytes32` which means we need to convert our address to bytes32.

```bash
bytes32 myAddress = bytes32(uint256(uint160(tx.origin)));
```

## Attack

Let's use Remix IDE to avoid compatibility (downgrade) issues with Foundry.

## Fix
