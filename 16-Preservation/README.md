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

1. Deploy `PreservationAttack.sol`

```bash
forge script script/DeployPreservationAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x8Db25dd3A01eeFAFaB3FbD776B1b3194d05BA436

2. Attack

```bash
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

To fix this vulnerability, you could use the `call` function instead of `delegatecall`, and move the `storedTime` variable to the library contracts. This way, the library contracts can't modify the storage of the `Preservation` contract. This would require a significant redesign of the contract.
