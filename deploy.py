import os
from web3 import Web3
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Ensure required environment variables are set
required_env_vars = ['INFURA_URL', 'SENDER_ADDRESS', 'PRIVATE_KEY', 'BYTECODE']
for var in required_env_vars:
    if not os.getenv(var):
        print(f"Error: Missing required environment variable: {var}")
        exit()

# Set up connection to Ethereum (Infura in this case)
infura_url = os.getenv('INFURA_URL')
w3 = Web3(Web3.HTTPProvider(infura_url))

# Ensure connection is successful
if not w3.is_connected():
    print("Failed to connect to Ethereum network!")
    exit()
else:
    print("Connected to Ethereum network.")

# Get the sender's address and private key from environment variables
sender_address = os.getenv('SENDER_ADDRESS')
private_key = os.getenv('PRIVATE_KEY')

# Define the bytecode from your .env file
bytecode = os.getenv('BYTECODE')

# Manually set nonce if needed (if the pending nonce is 2 as per the error message)
nonce = 4  # Adjust this manually based on the error message or block explorer

print(f"Current Nonce: {nonce}")

# Define the transaction details
transaction = {
    'chainId': 11155111,  # Sepolia test network chainId (update for other networks)
    'gas': 2000000,        # Gas limit
    'gasPrice': w3.to_wei('10', 'gwei'),
    'nonce': nonce
}

# Prepare the transaction for contract deployment
transaction.update({
    'data': bytecode
})

# Sign the transaction
try:
    signed_txn = w3.eth.account.sign_transaction(transaction, private_key)
except Exception as e:
    print(f"Error signing transaction: {e}")
    exit()

# Send the transaction
try:
    tx_hash = w3.eth.send_raw_transaction(signed_txn.raw_transaction)
    print(f"Transaction sent, hash: {tx_hash.hex()}")
except Exception as e:
    print(f"Error sending transaction: {e}")
    exit()

# Wait for the transaction to be mined
try:
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    print(f"Transaction mined! Contract deployed at address: {tx_receipt.contractAddress}")
except Exception as e:
    print(f"Error waiting for transaction receipt: {e}")
    exit()
