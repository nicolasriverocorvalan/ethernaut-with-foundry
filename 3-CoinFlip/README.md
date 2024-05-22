# CoinFlip

This is a coin flipping game where you need to build up your winning streak by guessing the outcome of a coin flip. To complete this level you'll need to use your psychic abilities to guess the correct outcome 10 times in a row.

## Vulnerability

### Predictability of the blockhash function

The `blockhash` function is used to get the hash of one of the 256 most recent blocks, but not including the current block. This means that the result of `blockhash(block.number - 1)` can be known by anyone as soon as the current block is mined.

In your flip function, you're using `blockhash(block.number - 1)` to determine the result of the coin flip. This means that anyone can predict the result of the coin flip as soon as the current block is mined, but before they call the flip function. This allows them to always win the coin flip.

Someone could exploit this vulnerability:

1. Wait for a new block to be mined.
2. Calculate `blockhash(block.number - 1) / FACTOR` and determine the result of the coin flip.
3. Call the flip function with the known result of the coin flip.

## Attack

Gets the hash of the most recent block, calculates the coin flip result, and then calls the flip function with the predicted outcome. It repeats this process 10 times to win the coin flip 10 times in a row.

The `CoinFlipAttack.sol` contract is designed to exploit the vulnerability in the `CoinFlip.sol` contract. Here's how it works:

The CoinFlipAttack contract imports the `CoinFlip.sol` contract and creates an instance of it using the address of the deployed `CoinFlip.sol` contract. This allows the `CoinFlipAttack.sol` contract to interact with the CoinFlip contract.

The predict function in the `CoinFlipAttack.sol` contract calculates the result of the next coin flip in the `CoinFlip.sol` contract. It does this by getting the hash of the most recent block and dividing it by `FACTOR`, just like the flip function in the `CoinFlip.sol` contract. This allows the `CoinFlipAttack.sol` contract to predict the result of the next coin flip.

The attack function in the `CoinFlipAttack.sol` contract calls the predict function to get the prediction and then calls the flip function in the `CoinFlip.sol` contract with the predicted result. This allows the `CoinFlipAttack.sol` contract to always win the coin flip.

By calling the attack function multiple times, you can win the coin flip in the `CoinFlip.sol` contract multiple times in a row.

1. Deploy `CoinFlipAttack.sol` using the cast deploy command.

```bash
forge script script/DeployCoinFlipAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0xaaC17BbbF3d6433b3d5DaA4704AF703D96F3F726
```

2. Attack

```bash
for i in {1..10}; do cast send $CONTRACT_ADDRESS "attack()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy;
; printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '-';  sleep 20; done
```

## Fix

Chainlink VRF (Verifiable Random Function) is a great choice for generating random numbers in a secure and verifiable way. It provides cryptographic proof that the number generated is truly random and cannot be manipulated.
