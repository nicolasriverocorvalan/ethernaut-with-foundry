# Denial

This is a simple wallet that drips funds over time. You can withdraw the funds slowly by becoming a withdrawing partner.

If you can deny the owner from withdrawing funds when they call withdraw() (whilst the contract still has funds, and the transaction is of 1M gas or less) you will win this level.

## Vulnerability

In Ethereum, every operation that is executed on the Ethereum Virtual Machine (EVM) consumes a certain amount of gas. Gas is a measure of computational effort. Each operation costs a fixed amount of gas. For example, a simple operation like adding two numbers might cost 3 gas, while a more complex operation like storing a value might cost 20,000 gas.

When you call a function in a contract, you specify a gas limit, which is the maximum amount of gas that the function is allowed to consume. If the function execution consumes all the gas before it finishes, it will be reverted, and all changes it made to the state will be undone. However, the gas is not refunded.

The total cost of a transaction (in Ether) is the product of the gas used and the gas price, which is specified in Gwei. The gas price is set by the person who sends the transaction, and it serves as an incentive for miners to include the transaction in the blockchain.

In Ethereum, when you're sending Ether from one contract to another, you have a few options: `call()`, `transfer()`, and `send()`. Each of these methods behaves differently in terms of how much gas they forward along with the Ether:

1. `call()`: This method forwards all available gas to the called contract unless a specific gas amount is specified. This means that if the called contract has a `receive` function, it can perform complex operations that require a lot of gas. However, this also makes it possible for `reentrancy` attacks to occur if the calling contract doesn't properly manage its state before calling another contract.

2. `transfer()` and `send()`: These methods only forward a stipend of `2300 gas` to the called contract. This is enough to log an event, but not enough to perform any state-changing operations. This makes `transfer()` and `send()` safer against `reentrancy` attacks, but it also means that they will fail if the called contract's `receive` function requires more than `2300 gas`.

In `Denial.sol` contract, the `withdraw()` function uses both `call()` and `transfer()` methods to send Ether. The `call()` method is used to send Ether to the `partner` address. The `call()` method forwards all available gas to the called contract unless a specific gas amount is specified. This means that if the partner contract has a `receive` function that requires a lot of gas, it can successfully execute because `call()` provides enough gas.

However, this also means that if the `partner` contract has a malicious `receive` function that consumes all available gas (for example, by running an infinite loop), the `call()` will run out of gas and fail. But since the `call()` method doesn't check the return value, the `withdraw()` function will continue executing even if the `call()` fails. 

However, because all the gas has been consumed, the subsequent `transfer()` to the `owner` will also fail due to out of gas.

## Attack

1. Deploy `DenialAttack.sol`

```bash
forge script script/DeployDenialAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x571A65F678FA1f4d4EDcABC62322e15f0A53F43E

2. Attack

```bash
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy
```

## Fix

You should follow the `Checks-Effects-Interactions` pattern. This means you should make any state changes before calling external contracts.

```bash
contract Denial {
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = msg.sender;

    function setWithdrawPartner(address _partner) external {
        partner = _partner;
    }

    function withdraw() public {
        uint amount = address(this).balance / 2; // calculate the split value

        // make state changes before calling external contracts
        (bool successPartner, ) = partner.call{value: amount}("");
        require(successPartner, "Partner transfer failed");

        (bool successOwner, ) = owner.call{value: amount}("");
        require(successOwner, "Owner transfer failed");
    }

    // deposit fallback
    receive() external payable {}
}
```

In this version of the `withdraw()` function, we first calculate the amount to be withdrawn. Then, we use the `call()` function to send the Ether and immediately check the return value. If the `call()` fails, the function will revert immediately, preventing any state changes. This way, we ensure that the state changes (the Ether transfers) only happen if both calls are successful, preventing `reentrancy` attacks.

## Notes
```
The receive() function is only called when the call data is empty, i.e., when someone just sends Ether to the contract without calling any function. It was introduced in Solidity 0.6.0 to clarify the intention of the contract author.

The fallback() function is called when no other function matches the function identifier, or when the contract was called with no data at all. It is also executed when a contract receives plain Ether (without data).
```
