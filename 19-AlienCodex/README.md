# Alien Codex

You've uncovered an Alien contract. Claim ownership to complete the level.

[ABI specifications](https://docs.soliditylang.org/en/v0.4.21/abi-spec.html)

## Vulnerability

In Ethereum smart contracts, storage is a key-value store that maps 256-bit words to 256-bit words. The first state variable that you declare in a contract is stored in slot 0, the second one in slot 1, and so on.

* `Slot 0`: The `contact` and `_owner` variables are both stored in `slot 0`. This is because `contact` is a `bool` which only takes up 1 byte, and `_owner` is an `address` which takes up 20 bytes. Together, they only take up 21 bytes, which is less than the 32 bytes available in a storage slot, so they can both fit in the same slot.

* `Slot 1`: The `codex.length` variable is stored in slot 1. This variable keeps track of the number of elements in the `codex` array.

* `Slots keccak256(1), keccak256(2) + 1, etc`: These slots are used to store the elements of the codex array. The `keccak256` function is used to calculate the storage slot for each element based on its index in the array.

* `Slot 2^256 - 1`: This slot is used to store the element at index `2^256 - 1 - uint(keccak256(1))` in the `codex` array. This is the result of an underflow, where subtracting 1 from 0 results in the maximum uint value.

* `Slot 0 (again)`: This slot is used to store the element at `index 2^256 - 1 - uint(keccak256(1)) + 1` in the `codex` array. This is also the result of an underflow, where adding 1 to the maximum `uint` value results in 0.

```bash
uint index = ((2 ** 256) - 1) - uint(keccak256(abi.encode(1))) + 1;
```

In the `AlienCodex` contract, the `owner` variable is inherited from the `Ownable` contract and is therefore not the first state variable declared. This means it's not stored in slot 0, but in a later slot.

1. `make_contact()` Function
Call the `make_contact()` function so that the `contact` variable is set to `true`. This will allow us to bypass the `contacted()` modifier.

2. `retract()` Function
Call the `retract()` function. This will decrease the `codex.length` by 1. When you subtract 1 from 0 (the initial array position), you get an underflow. This will allow us to access any storage slot in the contract.

3. `revise()` Function
Call the `revise()` function to access the array at slot 0 and update the `owner`'s value with our own address.

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

Let's deploy `AlienCodexAttack` using Remix IDE to avoid compatibility (Foundry downgrade) issues.

## Fix

```bash
function retract() public contacted {
    require(codex.length > 0, "No entries to retract");
    codex.length--;
}
```
