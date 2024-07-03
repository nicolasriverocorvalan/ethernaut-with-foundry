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

1. Determine the correct calldata.

The value to be loaded by `calldataload(4)` should be greater than 255 and must be placed correctly in the calldata. The function selector for `registerTreasury(uint8 _value)` can be obtained by taking the first 4 bytes of the keccak256 hash of the function signature.

We want to write a value greater than 255 to the `treasury` slot. To do this, we need to craft the calldata so that `calldataload(4)` reads the desired value. Since `calldataload` starts reading at the specified byte, placing our value right after the function selector should work. We'll use a value of 256 (0x0100) as an example.

Note: Solidity is big-endian, but Ethereum uses little-endian for storage, so we place the value accordingly.

2. Directly call `registerTreasury` with the crafted value.

This step requires directly interacting with the contract at a low level, as we need to ensure the data layout matches the expected format for exploitation. We use `address(higherOrder).call` to send the crafted calldata.

3. Claim leadership.

Instead of calling `claimLeadership` from within the `HigherOrderAttack` contract, ydirectly call `claimLeadership` from your EOA (Externally Owned Account). This ensures that `msg.sender` is your EOA, not the contract.

## Attack

1. Deploy `SwitchAttack`.

```bash
forge script script/DeployHigherOrderAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x90CbcB2AA98321f172710957AB311879bE186f14
```

2. Attack.

```bash
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy

# https://sepolia.etherscan.io/tx/0x5f50af7539178b70ec095ed140f75a3bf9a6a2df502e37d5814c19c4da262c34
```

3. `claimLeadership` from EOA.

```bash
cast send $HIGHER_ORDER_CONTRACT_ADDRESS "claimLeadership()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy

# https://sepolia.etherscan.io/tx/0x6541b1c5d705373b486b37eaac4bd573a81a22cb763cd19a83d6499496b8b5bc
```

## Fix

```bash
contract HigherOrder {
    address public commander;
    uint256 public treasury;

    # Event declarations for state changes
    event TreasuryRegistered(uint256 value);
    event LeadershipClaimed(address newCommander);

    # Modifier to restrict who can call the registerTreasury function
    modifier onlySpecificAddresses() {
        require(/* condition to allow specific addresses */, "Caller not authorized");
        _;
    }

    # Updated registerTreasury function with input validation and without direct assembly
    function registerTreasury(uint8 _value) public onlySpecificAddresses {
        // Assuming the logic intends to limit the treasury value to a certain range
        require(_value <= 255, "Value out of range");
        treasury = _value;
        emit TreasuryRegistered(_value);
    }

    # Updated claimLeadership function with event emission
    function claimLeadership() public {
        require(treasury > 255, "Only members of the Higher Order can become Commander");
        commander = msg.sender;
        emit LeadershipClaimed(msg.sender);
    }
}
```
