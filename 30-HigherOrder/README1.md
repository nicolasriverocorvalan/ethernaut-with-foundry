# Higher Order

Imagine a world where the rules are meant to be broken, and only the cunning and the bold can rise to power. Welcome to the Higher Order, a group shrouded in mystery, where a treasure awaits and a commander rules supreme.

Your objective is to become the Commander of the Higher Order! Good luck!

## SSTORE opcode

`SSTORE` is an opcode used by the Ethereum Virtual Machine (EVM) to store data in the contract's storage. Each contract deployed on Ethereum has its own storage, a key-value store where both keys and values are `32 bytes`. This storage is persistent between function calls and transactions, meaning the data stored in it remains until the contract is destroyed (Solidity 0.6.12)

The `SSTORE` opcode takes two parameters:

1. The key (storage location) to store the value in.
2. The value to be stored.

Solidity abstracts away the direct use of `SSTORE` and other opcodes for safety and ease of use. Instead of directly interacting with `SSTORE`, Solidity developers work with state variables. When you declare a state variable in a Solidity contract, the Solidity compiler automatically generates EVM bytecode that uses `SSTORE` and `SLOAD` (for loading data from storage) opcodes to manage these variables in the contract's storage.

```bash
# Example
pragma solidity ^0.6.12;

contract SimpleStorage {
    uint256 public myNumber; # This state variable is stored in the contract's storage

    function setMyNumber(uint256 _myNumber) public {
        myNumber = _myNumber; # This will use the SSTORE opcode to store _myNumber in storage
    }
}
```

## Vulnerability


## Attack


## Fix

