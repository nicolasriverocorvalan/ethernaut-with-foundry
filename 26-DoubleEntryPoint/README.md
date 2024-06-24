# Double Entry Point

This level features a `CryptoVault` with special functionality, the `sweepToken` function. This is a common function used to retrieve tokens stuck in a contract. The `CryptoVault` operates with an `underlying` token that can't be swept, as it is an important core logic component of the `CryptoVault`. Any other tokens can be swept.

The underlying token is an instance of the DET token implemented in the `DoubleEntryPoint` contract definition and the `CryptoVault` holds 100 units of it. Additionally the `CryptoVault` also holds 100 of `LegacyToken LGT`.

In this level you should figure out where the bug is in `CryptoVault` and protect it from being drained out of tokens.

The contract features a `Forta` contract where any user can register its own `detection bot` contract. `Forta` is a decentralized, community-based monitoring network to detect threats and anomalies on DeFi, NFT, governance, bridges and other Web3 systems as quickly as possible. Your job is to implement a detection bot and register it in the `Forta` contract. The bot's implementation will need to raise correct alerts to prevent potential attacks or bug exploits.

## Double Entry Point (DEP)

A `Double Entry Point (DEP)` in the context of token contracts is a security mechanism designed to protect smart contracts, especially those handling tokens, from unauthorized access or vulnerabilities.

While the term `Double Entry Point` isn't standard in Ethereum or smart contract development, the concept can be inferred to involve an additional layer of security or validation before certain actions can be performed, particularly those that could lead to the unauthorized movement of tokens.

### Conceptual Overview

1. `Standard Token Contract`: A typical token contract allows users to transfer tokens from one account to another. It includes functions like `transfer` and `approve`, which, if not properly secured, could be exploited.
2. `Double Entry Point Mechanism`: Introduces an additional layer or checkpoint before executing sensitive operations. This could be implemented in various ways, such as:
   - `Proxy Contracts`: A `DEP` might use a proxy contract that forwards calls to the main token contract. The proxy can contain additional checks or logic to validate transactions before they reach the token contract.
   - `Detection Bots`: A system like `Forta` allows for the registration of detection bots. These bots can monitor transactions for suspicious activity and potentially halt or flag transactions before they are executed, acting as a `DEP` by providing an additional validation step.


## Vulnerability

The vulnerability in the `DoubleEntryPoint.sol` contract arises from the interaction between the `CryptoVault`, `LegacyToken`, and `DoubleEntryPoint` contracts, specifically through the use of delegate calls and the manipulation of the `msg.sender` value. Here's a step-by-step explanation of how the vulnerability can be exploited:

1. `CryptoVault` contract is designed to hold tokens, including a special token represented by the `DoubleEntryPoint` contract (DET). The `LegacyToken` (LGT) contract is another token that can delegate its transfer function to the `DoubleEntryPoint` contract.

2. `LegacyToken` contract has a function `delegateToNewContract` that allows it to set the `DoubleEntryPoint` contract as its delegate. This means that calls to `LegacyToken.transfer` can be forwarded to `DoubleEntryPoint.delegateTransfer` via the delegate mechanism.

3. `CryptoVault` has a `sweepToken` function intended to allow the transfer of any token except its underlying token (to prevent draining the vault of its primary asset). However, this function does not account for the possibility of delegate calls changing the execution context.

4. The attacker convinces the vault to call `sweepToken` with the `LegacyToken` (LGT) as the target. The `sweepToken` function checks that `LGT` is not the underlying token and proceeds. It then calls `LegacyToken.transfer`, intending to transfer all `LGT` tokens to a recipient. Since `LegacyToken` has `DoubleEntryPoint` set as its delegate, the call is forwarded to `DoubleEntryPoint.delegateTransfer`.

5. In `DoubleEntryPoint.delegateTransfer`, the `onlyDelegateFrom` modifier checks that `msg.sender` is the `LegacyToken` contract, which is true in this case. The `fortaNotify` modifier is designed to detect suspicious transactions but does not prevent the execution if the `LegacyToken` is the caller.

6. The `delegateTransfer` function in `DoubleEntryPoint` executes, transferring `DET` tokens from the `CryptoVault` to the specified recipient. This effectively drains the `CryptoVault` of its `DET` tokens, bypassing the check in `sweepToken` that was supposed to prevent this exact scenario.






## Attack


## Fix

