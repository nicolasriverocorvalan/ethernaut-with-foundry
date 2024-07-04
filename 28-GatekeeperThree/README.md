# Gatekeeper Three

Cope with gates and become an entrant.

## Vulnerability

1. `gateOne` modifier:
   
```bash
modifier gateOne() {
    require(msg.sender == owner);
    require(tx.origin != owner);
    _;
}
```
The requirement that `msg.sender` must be the owner and `tx.origin` must not be the owner can be bypassed by a contract that is owned by the intended owner. An attacker could deploy a contract, make the owner of `GatekeeperThree` deploy another contract (or use an existing one they own), and then interact with `GatekeeperThree` through this contract. This setup would satisfy both conditions.

2. `gateTwo` modifier:

```bash
modifier gateTwo() {
    require(allowEntrance == true);
    _;
}
```

The `allowEntrance` boolean is set to `true` by calling `getAllowance` with the correct password. However, since the `SimpleTrick` contract's password is initially set to `block.timestamp` at the time of its deployment and can be reset to `block.timestamp` upon a failed password check, an attacker observing the block of deployment could guess or brute-force the password by trying values around the `block.timestamp` of the contract's creation.

3. `gateThree` modifier:

```bash
modifier gateThree() {
    if (address(this).balance > 0.001 ether && payable(owner).send(0.001 ether) == false) {
        _;
    }
}
```

- The contract's balance is indeed greater than `0.001` Ether.
- `payable(owner).send(0.001 ether) == false` being true indicates that the payment attempt failed.

1. Use of `tx.origin` for auth:

The use of `tx.origin` for auth in `gateOne` is generally discouraged because it can lead to vulnerabilities where an attacker tricks a user into executing a transaction that interacts with the vulnerable contract.

5. Public visibility of `createTrick`:

The `createTrick` function is public and allows any user to overwrite the `trick` contract instance stored in the `GatekeeperThree` contract. This could lead to unauthorized control over the mechanism that sets `allowEntrance` to true.

6. Re-entrancy in `gateThree`:

Although not a direct re-entrancy vulnerability due to the lack of state changes after the external call, relying on the external call's success or failure `payable(owner).send(0.001 ether)` to control the flow can be risky and lead to unexpected behavior, especially if the owner's address is a contract with a fallback function.

7. Lack of event logging:

The contract does not emit events for significant state changes (e.g., changing `allowEntrance`, updating `entrant`, +), making it harder to track its activity and debug issues.

To exploit this contract, an attacker could focus on manipulating the `SimpleTrick` contract to bypass the gates, especially by guessing or brute-forcing the `password` based on the deployment `block.timestamp`. Additionally, the attacker could exploit the public `createTrick` function to set up their version of the `SimpleTrick` contract, potentially bypassing the intended logic for setting `allowEntrance`.

## Attack

1. Deploy `GatekeeperThreeAttack` and the attack will be executed.

```bash
forge script script/DeployGatekeeperThreeAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0xbC4349e6BfeFd22982327DD1C64FC1c5BF4Ba874
```

2. Found `GatekeeperThree`.

```bash
cast send $GATEKEEPER_THREE_CONTRACT_ADDRESS --value 0.0011ether --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

3. Attack.

```bash
cast send $CONTRACT_ADDRESS "solveGateOne()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
cast send $CONTRACT_ADDRESS "solveGateTwo()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
cast send $CONTRACT_ADDRESS "solveGateThree()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```


## Fix

