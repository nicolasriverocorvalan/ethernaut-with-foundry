# Alien Codex

You've uncovered an Alien contract. Claim ownership to complete the level.

[ABI specifications](https://docs.soliditylang.org/en/v0.4.21/abi-spec.html)

## Vulnerability

The `retract` function decreases the length of the `codex` array by one, but it doesn't check if the array is empty. If the `retract` function is called when the array is empty, it will underflow and set the length of the array to a very large number. This will allow you to overwrite any location in memory, including the `owner` variable in the `Ownable` contract.

In Solidity, the storage layout of a contract is determined by the order in which variables are declared. The first state variable is stored in slot 0, the second state variable is stored in slot 1, and so on.

The `Ownable` contract has only one state variable, `owner`, so it's stored in slot 0. If `AlienCodex` doesn't declare any state variables before it inherits from `Ownable`, the owner variable will still be in slot 0. However, `AlienCodex` could declare state variables before it inherits from `Ownable`, which would push the owner variable to a higher slot.

The `AlienCodex` contract declares two state variables, `contact` and `codex`, before it inherits from `Ownable`. This means that the `owner` variable from the `Ownable` contract will be in the third slot of the contract's storage.

## Attack

## Fix
