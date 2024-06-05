# Magic Number

To solve this level, you need to provide the Ethernaut with a `Solver` contract that responds to `whatIsTheMeaningOfLife()` with the correct number.

Simple, right? However, there is a challenge.

The solver's code must be extremely small. Incredibly small. It must be no more than 10 opcodes in total.

Hint: It may be necessary to step away from the Solidity compiler momentarily and construct this contract manually using raw EVM bytecode.

## EVM (Ethereum Virtual Machine)

In Ethereum's EVM (Ethereum Virtual Machine), memory is a byte-array that can be accessed with byte-level granularity. It's a linear and word-addressable memory, where each word is 32 bytes wide.

[opcodes doc](https://ethereum.org/en/developers/docs/evm/opcodes/)

```bash
OPCODE       NAME
------------------
 0x60        PUSH1(value)
 0x52        MSTORE(position or offset, value) -> expects the value to be already stored in the memory
 0xf3        RETURN(position or offset, length/size of our stored data)
```

### `initialization opcodes`

The `initialization opcodes` are executed only once when the contract is created. They usually include code to set up the contract's storage and copy the runtime bytecode to memory (loading our runtime opcodes in memory and returning it to the EVM).

a. To copy the code, we need to use `CODECOPY(t, f, s)`:

`t`: destination position or offset where the code will be in memory.
`f`: current position or offset of the runtime opcode, which is not known as of now.
`s`: size of the runtime code in bytes, 10 bytes.

```bash
1. 0x60 - PUSH1 --> PUSH(0x0a) --> 0x600a (`s=0x0a` or 10 bytes)
2. 0x60 - PUSH1 --> PUSH(0x??) --> 0x60?? (`f` - This is not known yet)
3. 0x60 - PUSH1 --> PUSH(0x00) --> 0x6000 (`t=0x00` - arbitrary chosen memory location)
4. 0x39 - CODECOPY --> 0x39 (Calling the CODECOPY with all the arguments)
```

b. Return the runtime opcode to the EVM:

```bash
1. 0x60 - PUSH1 --> PUSH(0x0a) --> 0x600a (size of opcode is 10 bytes)
2. 0x60 - PUSH1 --> PUSH(0x00) --> 0x6000 (value was stored in slot 0x00)
3. 0xf3 - RETURN --> RETURN --> 0xf3 (Return value at p=0x00 slot and of size s=0x0a)
```
The initialization code is `600a60__600039600a6000f3` (12 bytes long), so the starting position of the `runtime code` is at index `12`, or `0x0c` in hexadecimal. 

```bash
# Therefore, 60__ is replaced with 0c, making the final bytecode 600a600c600039600a6000f3.
```

### `runtime opcodes`

Are the part of the bytecode that is executed whenever a function in the contract is called. They include the logic of the contract's functions.

Push and store our value (0x2a) in the memory:

```bash
1. `602a`: This is the `PUSH1` opcode, which pushes the next byte (`0x2a`, which is `42` in decimal) onto the stack. This value will be stored in memory in the next step.

`0x60 - PUSH1 --> PUSH(0x2a) --> 0x602a (Pushing 2a or 42)`

2. `6080`: This is another `PUSH1` opcode, which pushes the next byte (`0x80`) onto the stack. This will be the memory location where we'll store the number.

`0x60 - PUSH1 --> PUSH(0x80) --> 0x6080 (Pushing an arbitrary selected memory slot 80)`

3. `52`: This is the `MSTORE` opcode, which pops the top two stack items, and stores the second item at the memory location specified by the first item. In this case, it stores the number at the memory location we specified in the previous step.

`0x52 - MSTORE --> MSTORE --> 0x52 (position p=0x80 in memory, Store value v=0x2a)`
```

Return the stored value. Once we are done with the `PUSH` and `MSTORE`, it's time to return the value using `RETURN`:

```bash
1. `6020`: This is another `PUSH1` opcode, which pushes the next byte (`0x20`) onto the stack. This is the size of the memory to return (32 bytes).

`0x60 - PUSH1 --> PUSH(0x20) --> 0x6020 (Size of value is 32 bytes)`

2. `6080`: This is another `PUSH1` opcode, which pushes the next byte (`0x80`) onto the stack. This is the memory location where we stored the number.

`0x60 - PUSH1 --> PUSH(0x80) --> 0x6080 (Value was stored in slot 0x80)`

3. `f3`: This is the `RETURN` opcode, which pops the top two stack items, and returns the memory located at the second item and of length specified by the first item. In this case, it returns the number we stored in memory.

`0xf3 - RETURN --> RETURN --> 0xf3 (Return value at p=0x80 slot and of size s=0x20)`
```

```bash
# The resulting contract in bytecode is 602a60805260206080f3, which is exactly 10 bytes long, fitting within the maximum limit allowed.
```

```bash
# Final bytecode concatenate 600a600c600039600a6000f3 + 602a60805260206080f3 = 600a600c600039600a6000f3602a60505260206050f3
```

### `assembly`

`assembly` keyword is used to define a block of inline assembly code. Inline assembly allows you to write lower-level EVM code directly in your Solidity contract.

```bash
assembly {
    solver := create(0, add(code, 0x20), mload(code))
}
```

* `create`: an assembly function that creates a new contract. It takes three arguments:

1. The amount of wei to send to the new contract (in this case, 0).
2. The start of the memory area containing the contract's bytecode (in this case, `add(code, 0x20)`).
3. The size of the bytecode (in this case, `mload(code)`).

* `add(code, 0x20)`: this is adding 0x20 (32 in decimal) to the `code` variable. This is typically done to skip the length field that's included when a `bytes` variable is stored in memory.

* `mload(code)`: this is loading the value from memory at the location specified by `code`. In this context, it's used to get the size of the bytecode.

This code is creating a new contract with the bytecode specified by `code`, and it's assigning the address of the new contract to the `solver` variable.

### Deploy and verify solver address

```bash
forge script script/DeployMagicNumberAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0xF25f8bCa3e8C9afAbB8d3fCF8904fCd85856110F
```

```bash
cast call $CONTRACT_ADDRESS "solver()" --rpc-url $ALCHEMY_RPC_URL --legacy

0x000000000000000000000000f25f8bca3e8c9afabb8d3fcf8904fcd85856110f
```
