# Telephone

## Externally Owned Account (EOA)

EOA are accounts controlled by private keys and have no associated code. They can send transactions (including Ether transfers) to other EOAs or to contract accounts by creating and signing a transaction with their private key.

In contrast, contract accounts are controlled by their contract code and can only perform an action (like sending Ether) when instructed to do so by an EOA.

So, when a transaction is initiated, it's always started by an EOA, and that's what `tx.origin` refers to. `msg.sender` can be either an EOA or a contract account, depending on whether the call was made directly by an EOA or forwarded through a contract.

## Vulnerability

```javascript
function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
        owner = _owner;
    }
}
````

The vulnerability in this Solidity function lies in the use of `tx.origin` for authorization.

`msg.sender` is the address of the entity (contract or EOA) directly interacting with the contract, while `tx.origin` is the address of the original entity that started the transaction (always an EOA).

The condition `tx.origin != msg.sender` is true when the function is called by a contract which was itself called by an EOA. This means that if an attacker creates a malicious contract and tricks the original owner into calling it, the malicious contract can then call changeOwner and take ownership of the contract.

## Attack

### Flow
1. Attacker creates a malicious contract.
2. Attacker tricks the original owner into calling a function in the malicious contract.
3. The malicious contract calls `changeOwner`, passing its own address as _owner.
4. Since `tx.origin` (the original owner) is not the same as `msg.sender` (the malicious contract), the condition is true and the ownership is transferred to the attacker.

### Foundry

1. Deploy `TelephoneAttack.sol` using the cast deploy command.

```bash
forge script script/DeployTelephoneAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x702D93285128BFE7fdd63bB7aF0fAfA8121a8D75
```
2. Attack

```bash
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

To fix this vulnerability, you should use `msg.sender` for authorization checks instead of `tx.origin`. This ensures that only the entity directly interacting with the contract can change the owner

```javascript
modifier onlyOwner {
    require(msg.sender == owner, "Only the current owner can change the owner");
    _;
}

function changeOwner(address _owner) public onlyOwner {
    owner = _owner;
}
```
