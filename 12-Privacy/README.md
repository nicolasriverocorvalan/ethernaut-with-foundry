# Privacy

The creator of this contract was careful enough to protect the sensitive areas of its storage. Unlock this contract to beat the level.

## Vulnerability

Each storage slot in Solidity can hold 32 bytes. Variables are packed into these slots where possible, and arrays always start a new slot. The third entry of the data array (at index 2) is stored in slot 5.

In Ethereum, storage is a key-value store that maps 256-bit words to 256-bit words. However, Solidity is more flexible and offers types that take less than 256 bits. These smaller types can be packed into a single storage slot to save storage space and reduce gas costs.

1. `locked` is 1 byte bool in slot 0. The locked variable is a boolean, which takes up 1 byte. It's the first variable declared, so it goes into the first storage slot (slot 0).

2. `ID` is a 32 byte uint256. The `ID` variable is a uint256, which takes up 32 bytes. It can't fit into slot 0 with locked because it's too large, so it goes into the next available slot (slot 1) and fills it completely.

3. `flattening` a 1 byte uint8, `denomination` a 1 byte uint8 and `awkwardness` a 2 byte uint16 totals 4 bytes. Are all small enough to fit into a single slot. They take up 1 byte, 1 byte, and 2 bytes respectively, for a total of 4 bytes. So, they all go into the next available slot (slot 2).
   
4. `Array data always start a new slot`, so data starts from slot 3. The `data` variable is an array, which always starts in a new slot. So, it starts in the next available slot (slot 3). Each element of the array is a bytes32, which takes up 32 bytes (one full slot). So, the first element (data[0]) is in slot 3, the second element (data[1]) is in slot 4, and the third element (data[2]) is in slot 5.

5. `_key == bytes16(data[2])`: This is the condition being checked. It's comparing `_key` with the third element of the data array (arrays in Solidity are 0-indexed, so data[2] is the third element).

## Attack

```bash
python unlock.py
Hex key to be used: 0x473acaff01de2ba868fd9aca0164c76f
```

```bash
cast send $CONTRACT_ADDRESS "unlock(bytes16)" 0x473acaff01de2ba868fd9aca0164c76f --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

```bash
// Add an owner variable and set it in the constructor
address private owner;

constructor() public {
    owner = msg.sender;
}

modifier onlyOwner {
    require(msg.sender == owner, "Not contract owner");
    _;
}

// Change the unlock function to use the onlyOwner modifier
function unlock(bytes16 _key) public onlyOwner {
    require(_key == bytes16(data[2]));
    // Rest of the function
}
```
