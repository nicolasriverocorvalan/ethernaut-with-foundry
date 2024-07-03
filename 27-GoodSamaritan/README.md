# Good Samaritan

This instance represents a Good Samaritan that is wealthy and ready to donate some coins to anyone requesting it.

Would you be able to drain all the balance from his Wallet?

Things that might help:

[Solidity Custom Errors](https://soliditylang.org/blog/2021/04/21/custom-errors/)

## Vulnerability

1. The attacker calls `requestDonation()` on the `GoodSamaritan` contract.
2. Inside `requestDonation()`, the contract attempts to donate 10 coins to the caller by calling `wallet.donate10(msg.sender)`.
3. If the donation attempt is successful, `wallet.donate10` will internally call `coin.transfer()` to move the coins.
4. Design an attacker's contract to have a `notify()` function. When `coin.transfer()` checks if the recipient address is a contract and calls `notify()`, the attacker's `notify()` function intentionally reverts with a custom error named `NotEnoughBalance()`.
5. The custom error causes the `try-catch` block in `requestDonation()` to catch the error. Since the error matches the condition for `NotEnoughBalance()`, the `wallet.transferRemainder(msg.sender)` is executed, intending to transfer remaining tokens to the attacker.

## Attack

- The `GoodSamaritan` contract is designed to donate coins to anyone requesting it through the `requestDonation()` function. It uses a `Wallet` contract to manage the donation and a `Coin` contract to handle the actual transfer of coins.
- When an attacker calls `requestDonation()` on the `GoodSamaritan` contract, the contract attempts to donate 10 coins to the caller by calling `wallet.donate10(msg.sender)`.
- The `Wallet` contract's donate10 function calls the `Coin` contract's transfer function to move 10 coins to the requester. If the recipient is a contract (as it would be in the case of an attack), the `Coin` contract's `transfer` function attempts to notify the recipient by calling its `notify(uint256 amount)` function.
- The attacker's contract implements a `notify` function that reverts with a custom error `NotEnoughBalance()` if the amount is less than or equal to 10. This custom error is specifically crafted to trigger a catch block in the `GoodSamaritan` contract.
- The `GoodSamaritan` contract's `requestDonation()` function has a `try-catch` block that catches errors from the `wallet.donate10` call. If the caught error matches the signature of `NotEnoughBalance()`, the contract assumes there's not enough balance to donate 10 coins and proceeds to transfer the remainder of the wallet's balance to the requester by calling `wallet.transferRemainder(msg.sender)`.
- The vulnerability must be exploited by the attacker's contract intentionally failing with `NotEnoughBalance()` when 10 coins are attempted to be transferred to it. This failure triggers the `GoodSamaritan` contract to transfer the remainder of its balance to the attacker, instead of just the intended 10 coins.

1. Check initial balance.

```bash
# Coin address contract: 0x04BE262c1f2D1b2EFd7eBaaAeD584b8222661916
# initial wallet: 0x2579F0110118287298aE5428539FEe6Db5C55068

cast call 0x04BE262c1f2D1b2EFd7eBaaAeD584b8222661916 "balances(address)(uint256)" 0x2579F0110118287298aE5428539FEe6Db5C55068 --rpc-url $ALCHEMY_RPC_URL --legacy
# 1000000 [1e6]
```

1. Deploy `GoodSamaritanAttack`.

```bash
forge script script/DeployGoodSamaritanAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0x6147bE8Dba9D155875CF4cf9F771212Ef2be6aF5
```

3. Attack

```bash
cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy

# https://sepolia.etherscan.io/tx/0x3e47361ae94bbb4ad798347a9d5b88b27913086c787746b390e9ae800aa366bb
```

4. Check balance after attack.

```bash
# Coin address contract: 0x04BE262c1f2D1b2EFd7eBaaAeD584b8222661916
# initial wallet: 0x2579F0110118287298aE5428539FEe6Db5C55068

cast call 0x04BE262c1f2D1b2EFd7eBaaAeD584b8222661916 "balances(address)(uint256)" 0x2579F0110118287298aE5428539FEe6Db5C55068 --rpc-url $ALCHEMY_RPC_URL --legacy
# 0
```

## Fix

Contracts should avoid making assumptions based on the execution outcome of external contract calls, especially when those calls are to untrusted contracts. Additionally, using more precise checks and conditions, rather than relying on custom errors for control flow, can help prevent such exploits.

```bash
#Importing a reentrancy guard from OpenZeppelin's contracts library
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract GoodSamaritan is ReentrancyGuard {
    mapping(address => uint256) public pendingWithdrawals;

    # Other contract variables and functions

    function requestDonation() external nonReentrant {
        uint256 donationAmount = 10;
        uint256 walletBalance = wallet.getBalance();

        if (walletBalance >= donationAmount) {
            # Attempt to donate 10 coins
            bool success = wallet.donate10(msg.sender);
            if (!success) {
                revert("Donation failed");
            }
        } else {
            # Instead of transferring directly, update the pending withdrawals
            pendingWithdrawals[msg.sender] += walletBalance;
            # Assuming a function that safely empties the wallet to this contract
            wallet.transferAllTo(address(this));
        }
    }

    function withdraw() public nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No funds available for withdrawal");

        # Reset the pending withdrawal before transferring to prevent reentrancy
        pendingWithdrawals[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    # Additional functions as needed
}
```
