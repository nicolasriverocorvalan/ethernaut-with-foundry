# Preservation

This contract utilizes a library to store two different times for two different timezones. The constructor creates two instances of the library for each time to be stored.

The goal of this level is for you to claim ownership of the instance you are given.

## Vulnerability

`delegatecall` is a low-level function in Solidity that allows a contract to call another contract's function as if the function was being called from the original contract. This means that the function that is called via `delegatecall` has access to the storage of the calling contract.

```bash
contract A { # called contract
    uint public num;
    function setNum(uint _num) public {
        num = _num;
    }
}

contract B { # calling contract
    uint public num;
    function setNum(address _a, uint _num) public {
        (bool success,) = _a.delegatecall(abi.encodeWithSignature("setNum(uint256)", _num));
        require(success);
    }
}
```

If `contract B` calls `setNum` on `contract A` using `delegatecall`, the `num` variable in `contract B` will be updated, not the `num` variable in `contract A`. This is because `delegatecall` executes the code in the context of the calling contract (B), not the called contract (A).

`delegatecall` is often used for `upgradeable contracts`, where the logic of a contract can be updated by changing the address of the contract that is called via `delegatecall`.

However, `delegatecall` can be dangerous if not used carefully, because it allows the called contract (A) to modify the storage of the calling contract (B). This can lead to unexpected behavior if the storage layouts of the two contracts are not compatible.

## Attack

a. Create an instance of the `Preservation` contract in our own contract (`PreservationAttack`).

b. Call the `attack()` function. This function first calls `setFirstTime` on the `Preservation` contract with the address of the `PreservationAttack` contract. Because `setFirstTime` uses delegatecall, this effectively changes the `timeZone1Library` address in the `Preservation` contract to the address of the `PreservationAttack` contract.

c. Then we call `setFirstTime` again, this time with our own address. Because `timeZone1Library` now points to the `PreservationAttack` contract, this call actually executes the `setTime` function in the `PreservationAttack` contract.

d. The `setTime` function in the `PreservationAttack` contract changes the owner of the `Preservation` contract to the attacker's address. This is possible because `delegatecall` executes the function in the context of the calling contract, so it has access to the `Preservation` contract's storage.

Finally, the `attack()` function checks if the owner of the `Preservation` contract is now the attacker's address. If it is, the attack was successful.

1. Deploy `PreservationAttack.sol`

```bash
forge script script/DeployPreservationAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0xB91333D990dF69136AaFCff562f0e3a0E6d541ea

2. Attack

```bash
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

This attack is possible because the `Preservation` contract uses `delegatecall` without properly validating the addresses it's calling.

To fix this vulnerability, you could use the `call` function instead of `delegatecall`, and move the `storedTime` variable to the library contracts. This way, the library contracts can't modify the storage of the `Preservation` contract. This would require a significant redesign of the contract.

## Notes

`abi.encodePacked` is a function in Solidity that takes one or more arguments, and returns a tightly packed concatenation of the binary representations of those arguments.

`timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));`

`abi.encodePacked(setTimeSignature, _timeStamp)` is creating a tightly packed binary representation of the `setTimeSignature` and `_timeStamp` variables.

This encoded data is then passed as the data payload to the `delegatecall` function. The `delegatecall` function will execute the function specified by `setTimeSignature` in the `timeZone1Library` contract, with `_timeStamp` as the argument.

The reason for using `abi.encodePacked` here is to create the correct data payload for the `delegatecall` function. The `delegatecall` function requires `the function signature` and `arguments` to be passed as a single bytes array, and `abi.encodePacked` provides a convenient way to create this array.
