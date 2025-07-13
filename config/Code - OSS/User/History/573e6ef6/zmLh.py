# Example Hardhat script using web3.py
from web3 import Web3

# Connect to the Hardhat network
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))

# Check connection
if w3.is_connected():
    print("Connected to Hardhat network")
else:
    print("Failed to connect to Hardhat network")

# Example: Get accounts
accounts = w3.eth.accounts
print("Accounts:", accounts)

# Example: Get balance of an account
balance = w3.eth.get_balance(accounts[0])
print(f"Balance of {accounts[0]}: {w3.from_wei(balance, 'ether')} ETH")