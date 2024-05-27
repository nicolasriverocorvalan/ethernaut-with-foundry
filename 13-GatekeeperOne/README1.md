# Gatekeeper One

Make it past the gatekeeper and register as an entrant to pass this level.

## Vulnerability

a. `gateOne` modifier checks if `msg.sender` is not equal to `tx.origin`. Here's what this means:

1. `msg.sender` is a special global variable in Solidity that contains the address of the caller of the current function. If a contract function is called by another contract, `msg.sender` will be the address of that contract.

2. `tx.origin` is another special global variable in Solidity that contains the address of the original sender of the transaction. This is the `address of the externally owned account (EOA)` that initiated the transaction. If a contract function is called by another contract, `tx.origin` will still be the address of the EOA, not the contract.

b. `gateTwo` modifier checks if the remaining gas at the point of execution is a multiple of 8191. Here's what this means:

1. `gasleft()` is a built-in function in Solidity that returns the amount of gas still available for computation in the current function call.

2. The `%` operator is the modulus operator in Solidity. It returns the remainder of the division of the number on the left by the number on the right. So, `gasleft() % 8191` returns the remainder of the division of the remaining gas by 8191.

c. The `gateThree` modifier takes a `bytes8` argument `_gateKey` and checks three conditions using the `require` function. If any of these conditions are not met, the function call will fail and an error message will be returned.

1. `require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");`: This line checks if the last 16 bits of `_gateKey` are equal to the last 32 bits. This is done by first converting `_gateKey` to a uint64, then taking the last 32 bits (with uint32) and the last 16 bits (with uint16), and comparing them.

2. `require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");`: This line checks if the last 32 bits of _gateKey are not equal to the full _gateKey. This is done by converting `_gateKey` to a uint64, taking the last 32 bits (with uint32), and comparing it to the full `_gateKey`.

3. `require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");`: This line checks if the last 32 bits of `_gateKey` are equal to the last 16 bits of the transaction origin (`tx.origin`). This is done by converting `_gateKey` and `tx.origin` to uint64 and uint160 respectively, taking the last 32 bits of `_gateKey` and the last 16 bits of `tx.origin`, and comparing them.

## Attack

## Fix

