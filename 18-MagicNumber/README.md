# Magic Number

To solve this level, you only need to provide the Ethernaut with a `Solver`, a contract that responds to `whatIsTheMeaningOfLife()` with the right number.

Easy right? Well... there's a catch.

The solver's code needs to be really tiny. Really really tiny. Like freakin' really really itty-bitty tiny: 10 opcodes at most.

Hint: Perhaps its time to leave the comfort of the Solidity compiler momentarily, and build this one by hand. That's right: Raw EVM bytecode.

## EVM (Ethereum Virtual Machine)

[opcodes doc](https://ethereum.org/en/developers/docs/evm/opcodes/)

In Ethereum's EVM (Ethereum Virtual Machine), memory is a byte-array that can be accessed with byte-level granularity. It's a linear and word-addressable memory, where each word is 32 bytes wide.

### `initialization opcodes` and `runtime opcodes` 

Are two important parts of a contract's bytecode:

1. The `initialization opcodes` are executed only once when the contract is created. They usually include code to set up the contract's storage and copy the runtime bytecode to memory.

2. The `runtime opcodes` are the part of the bytecode that is executed whenever a function in the contract is called. They include the logic of the contract's functions.

```bash
OPCODE       NAME
------------------
 0x60        PUSH1(value)
 0x52        MSTORE(position or offset, value) -> expects the value to be already stored in the memory
 0xf3        RETURN(position or offset, length/size of our stored data)
```

### Push and store our value (0x2a) in the memory:

1. `602a`: This is the `PUSH1` opcode, which pushes the next byte (`0x2a`, which is `42` in decimal) onto the stack. This value will be stored in memory in the next step.

`0x60 - PUSH1 --> PUSH(0x2a) --> 0x602a (Pushing 2a or 42)`

2. `6080`: This is another `PUSH1` opcode, which pushes the next byte (`0x80`) onto the stack. This will be the memory location where we'll store the number.

`0x60 - PUSH1 --> PUSH(0x80) --> 0x6080 (Pushing an arbitrary selected memory slot 80)`

3. `52`: This is the `MSTORE` opcode, which pops the top two stack items, and stores the second item at the memory location specified by the first item. In this case, it stores the number at the memory location we specified in the previous step.

`0x52 - MSTORE --> MSTORE --> 0x52 (position p=0x80 in memory, Store value v=0x2a)`

- first opcode: `602a608052`

### Return the stored value

Once we are done with the `PUSH` and `MSTORE`, it's time to return the value using RETURN.

1. `6020`: This is another `PUSH1` opcode, which pushes the next byte (`0x20`) onto the stack. This is the size of the memory to return (32 bytes).

`0x60 - PUSH1 --> PUSH(0x20) --> 0x6020 (Size of value is 32 bytes)`

2. `6080`: This is another `PUSH1` opcode, which pushes the next byte (`0x80`) onto the stack. This is the memory location where we stored the number.

`0x60 - PUSH1 --> PUSH(0x80) --> 0x6080 (Value was stored in slot 0x80)`

3. `f3`: This is the `RETURN` opcode, which pops the top two stack items, and returns the memory located at the second item and of length specified by the first item. In this case, it returns the number we stored in memory.

`0xf3 - RETURN --> RETURN --> 0xf3 (Return value at p=0x80 slot and of size s=0x20)`

- second opcode: `60206080`

The resulting contract in bytecode is `602a60805260206080f3`, which is exactly 10 bytes long, fitting within the maximum limit allowed.

