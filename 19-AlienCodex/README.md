# Alien Codex

You've uncovered an Alien contract. Claim ownership to complete the level.

[ABI specifications](https://docs.soliditylang.org/en/v0.4.21/abi-spec.html)

## Vulnerability

The `retract` function decreases the length of the `codex` array by one, but it doesn't check if the array is empty. If the `retract` function is called when the array is empty, it will underflow and set the length of the array to a very large number. This will allow you to overwrite any location in memory, including the `owner` variable in the `Ownable` contract.



## Attack

## Fix
