from web3 import Web3
from dotenv import load_dotenv
import os

# Load the .env file
load_dotenv()

endpoint = os.getenv('ALCHEMY_RPC_URL')

# Connect to the Ethereum node
web3 = Web3(Web3.HTTPProvider(endpoint))

# The address of the contract
contract_address = os.getenv('CONTRACT_ADDRESS')

# The position of data in storage
position = 5

# Get the password
key = (web3.eth.get_storage_at(contract_address, position)).hex()

# Slice the key
key = key[:34]

print('Hex key to be used:', key)
