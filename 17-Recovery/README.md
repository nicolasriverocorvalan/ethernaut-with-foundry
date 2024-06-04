# Recovery

A contract creator has developed a simple token factory contract that allows anyone to easily create new tokens. After deploying the first token contract, the creator sent 0.001 ether to it. However, they have since lost the address of this first token contract.

To complete this challenge, you need to recover or remove the 0.001 ether from the lost contract address.

## Vulnerability

We need to locate the lost contract address. Once we have it, we can call the `destroy()` function on the contract to withdraw the funds, since the function is publicly accessible. We must derive the lost address.

Creating a specific `Ethereum` address using a deterministic computation involves generating an address that can be reliably reproduced given the same inputs. This is often done using a hash function, which takes an input (or 'message') and returns a fixed-size string of bytes.

`lostContract = payable(address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), recoveryAddress , bytes1(0x01)))))));`

a. `abi.encodePacked(bytes1(0xd6), bytes1(0x94), recoveryAddress , bytes1(0x01))`: This line is packing the provided arguments into a single bytes array. `abi.encodePacked` is used for tight packing of the arguments. `bytes1(0xd6)`, `bytes1(0x94)`, and `bytes1(0x01)` are bytes of length 1 with the given hexadecimal values, and `recoveryAddress` is an address.

b. `keccak256(...)`: This line is hashing the packed bytes array using the `Keccak-256` hash function, which is the standard hash function in `Ethereum`.

c. `uint256(...`): This line is casting the `Keccak-256` hash to a `256-bit` unsigned integer.

d. `uint160(...)`: This line is further casting the `256-bit` unsigned integer to a `160-bit` unsigned integer. `Ethereum` addresses are `160 bits` long, so this step is necessary to get a valid Ethereum address from the hash.

e. `address(...)`: This line is casting the `160-bit` unsigned integer to an address.

f. `payable(...)`: This line is casting the address to a payable address. A payable address can receive Ether.

g. `lostContract = ...`: This line is assigning the computed payable address to the lostContract state variable.

## Attack

1. Deploy `RecoveryAttack.sol`

```bash
forge script script/DeployRecoveryAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x6f5c067b429652Bfa30e06227307f17eAdEfc76A

2. Attack

```bash
cast send $CONTRACT_ADDRESS "computeAddress()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy

cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

`destroy` function is publicly accessible, add some access control to prevent unauthorized users from calling this function. Contract must be refactored.

## Notes: Creating a deterministic Ethereum address

Creating a deterministic Ethereum address, is the rightmost 160 bits of the `Keccak-256` hash of the RLP (Recursive Length Prefix) encoding of the sender's address and their nonce.

1. `sender address`: This is represented by `recoveryAddress` in the code. It's the address that created the contract.

2. `nonce`: This is represented by `bytes1(0x01)` in the code. The `nonce` is the number of contracts created by the sender address. In this case, it's assumed to be 1, which is the first contract created by the sender.

3. `RLP: Recursive Length Prefix (RLP)` is a method used in `Ethereum` to encode arbitrarily nested arrays of binary data. It's the primary encoding method used to serialize objects in `Ethereum`.

4. `bytes1(0xd6)`, `bytes1(0x94)`: These are the `RLP encoding` for a 20-byte address. According to the `RLP` specification, a single byte whose value is in the `[0x00, 0x7f] range` is RLP-encoded as itself, but longer strings have a prefix added. In this case, the prefix for a 20-byte string is `0xd6`, and `0x94` is the first byte of the address.

5. `bytes1(0x01)`: This is the `RLP` encoding for the nonce 1. According to the `RLP` specification, a single byte whose value is in the `[0x00, 0x7f]` range is RLP-encoded as itself, so 1 is encoded as 0x01.
