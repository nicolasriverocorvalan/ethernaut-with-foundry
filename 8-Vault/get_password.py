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

# The position of the password in storage
position = 1

# Get the password
password_hex = (web3.eth.get_storage_at(contract_address, position)).hex()
print('Hex password:', password_hex)

# Remove the '0x' prefix
hex_string = password_hex[2:]

# Convert to bytes and then decode to a string
password_plain = bytes.fromhex(hex_string).decode('utf-8')
print('Plain password:', password_plain)
