# Elevator

This elevator won't let you reach the top of your building. Right?

## Vulnerability

`Elevator` contract interacts with a `Building` interface. The `Elevator` contract has a `goTo` function that changes the current floor of the elevator.

There is a potential vulnerability in the `goTo` function. The function assumes that `msg.sender` is a `Building` interface and calls the `isLastFloor` function of `msg.sender`. This could be a risk if it's a malicious `Building` contract.

## Attack

1. The malicious contract implements the `Building` interface and the `isLastFloor` function in a way that it always returns `false` when it's called the first time and `true` when it's called the second time.
   
2. The malicious contract calls the `goTo` function of the `Elevator` contract. The `goTo` function calls the `isLastFloor` function of the malicious contract (`msg.sender` is the malicious contract), which returns `false`, so the floor of the Elevator contract is changed.

3. The `goTo` function calls the `isLastFloor` function of the malicious contract again, which now returns `true`, so the `top` of the Elevator contract is set to `true`.


1. Deploy `ElevatorAttack.sol`

```bash
forge script script/DeployElevatorAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0xDBe12eBd9FE32082d1954d3e0D476DC1550A0C88
```
2. Attack

```bash
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

1. When you call `attack`, it calls `elevator.goTo(1)`.
2. Inside `goTo`, it first calls `isLastFloor` on the `Building`contract (which in this case is the `ElevatorAttack` contract). This is the first call to `isLastFloor`.
3. If `isLastFloor` returns `false`, `goTo` sets the floor to the specified floor (1 in this case).
Then `goTo` calls `isLastFloor` again and sets the top state variable based on its return value. This is the second call to `isLastFloor`.

## Fix

Do not trust `msg.sender` to be a `Building` interface. Instead, you should store the address of the `Building` interface in a state variable and use this variable in the `goTo` function.

```bash
contract Elevator {
    bool public top;
    uint256 public floor;
    Building public building;

    constructor(Building _building) {
        building = _building;
    }

    function goTo(uint256 _floor) public {
        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}
```

The `goTo` function uses this state variable instead of `msg.sender`. This way, the `Elevator` contract always interacts with the correct `Building` interface.
