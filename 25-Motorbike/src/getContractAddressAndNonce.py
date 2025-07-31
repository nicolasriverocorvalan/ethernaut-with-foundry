from eth_utils import keccak, to_checksum_address
import rlp
from web3 import Web3
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Connect to an Ethereum node, replace the URL with your node's URL
node_url = os.getenv("ALCHEMY_RPC_URL")
web3 = Web3(Web3.HTTPProvider(node_url))

def get_nonce(sender):
    if not web3.is_connected():
        print("Failed to connect to Ethereum node.")
    else:    
        # Get the nonce for the sender address
        nonce = web3.eth.get_transaction_count(sender)
        print(f"Nonce for {sender}: {nonce}")
        return nonce

def get_contract_address(sender, nonce):
    """
    Calculate the Ethereum contract address based on sender and nonce.
    
    :param sender: The sender's address as a hex string.
    :param nonce: The nonce (transaction count) as an integer.
    :return: The calculated contract address as a checksummed hex string.
    """
    # Ensure the sender is in the correct format (bytes)
    if isinstance(sender, str):
        sender = bytes.fromhex(sender.removeprefix("0x"))
    
    # RLP encode sender and nonce
    encoded = rlp.encode([sender, nonce])
    
    # Keccak-256 hash of the RLP encoded structure
    hashed = keccak(encoded)
    
    # The rightmost 160 bits (20 bytes) is the contract address
    contract_address = hashed[-20:]
    
    # Convert to checksum address format
    return to_checksum_address(contract_address)

sender_address = os.getenv("MOTORBIKE_LEVEL_ADDRESS")
nonce = get_nonce(sender_address)
contract_address = get_contract_address(sender_address, nonce)
contract_address_plus_one = get_contract_address(sender_address, nonce + 1)
print(f"Calculated Contract Address (Engine): {contract_address}")
print(f"Calculated Contract Address nonce+1 (Instance): {contract_address_plus_one}")
