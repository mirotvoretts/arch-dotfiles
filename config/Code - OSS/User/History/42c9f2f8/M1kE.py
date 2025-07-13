from web3 import Web3
from fastapi import FastAPI
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

w3 = Web3(Web3.HTTPProvider(os.getenv("WEB3_PROVIDER_URI")))

@app.get("/check_connection")
def check_connection():
    is_connected = w3.is_connected()
    return {"connected": is_connected}

@app.get("/get_balance/{address}")
def get_balance(address: str):
    try:
        balance_wei = w3.eth.get_balance(address)
        balance_eth = Web3.from_wei(balance_wei, 'ether')
        return {
            "address": address,
            "balance_wei": balance_wei,
            "balance_eth": float(balance_eth)
        }
    except Exception as e:
        return {"error": str(e)}

@app.get("/send_eth/{to_address}/{amount_eth}")
def send_eth(to_address: str, amount_eth: float):
    try:
        account = w3.eth.account.from_key(os.getenv("PRIVATE_KEY"))
        
        tx = {
            'to': to_address,
            'value': Web3.to_wei(amount_eth, 'ether'),
            'gas': 21000,
            'gasPrice': Web3.to_wei('50', 'gwei'),
            'nonce': w3.eth.get_transaction_count(account.address),
            'chainId': 1337 
        }
        
        signed_tx = w3.eth.account.sign_transaction(tx, account.key)
        tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
        
        return {
            "message": "Transaction sent",
            "tx_hash": tx_hash.hex(),
            "from": account.address,
            "to": to_address,
            "amount_eth": amount_eth
        }
    except Exception as e:
        return {"error": str(e)}