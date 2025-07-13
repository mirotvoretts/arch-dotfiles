import json
import os
from web3 import Web3
from dotenv import load_dotenv

load_dotenv()


RPC_URL = os.getenv("RPC_URL")
ORGANIZATION_PRIVATE_KEY = os.getenv("ORGANIZATION_PRIVATE_KEY")
PLATFORM_REGISTRY_ADDRESS = os.getenv("PLATFORM_REGISTRY_ADDRESS")

REGISTRY_ABI_PATH = "../../artifacts/contracts/CharityCampaign.sol/CharityCampaign.json"
CAMPAIGN_ABI_PATH = "../../artifacts/contracts/PlatformRegistry.sol/PlatformRegistry.json"

class BlockchainUtil:
    """
    Класс-утилита для инкапсуляции всех взаимодействий со смарт-контрактами.
    """
    def init(self):
        if not all([RPC_URL, ORGANIZATION_PRIVATE_KEY, PLATFORM_REGISTRY_ADDRESS]):
            raise ValueError("Не установлены все необходимые переменные окружения для блокчейна.")

        self.w3 = Web3(Web3.HTTPProvider(RPC_URL))
        if not self.w3.is_connected():
            raise ConnectionError(f"Не удалось подключиться к Ethereum ноде по адресу {RPC_URL}")

        self.account = self.w3.eth.account.from_key(ORGANIZATION_PRIVATE_KEY)
        self.w3.eth.default_account = self.account.address

        self._registry_abi = self._load_abi(REGISTRY_ABI_PATH)
        self._campaign_abi = self._load_abi(CAMPAIGN_ABI_PATH)
        
        self.registry_contract = self.w3.eth.contract(
            address=Web3.to_checksum_address(PLATFORM_REGISTRY_ADDRESS),
            abi=self._registry_abi
        )
    
    def _load_abi(self, path: str) -> dict:
        with open(path, 'r') as f:
            return json.load(f)

    def _send_transaction(self, tx: dict):
        """Хелпер для подписи, отправки и ожидания транзакции."""

        if 'gas' not in tx:
            tx['gas'] = self.w3.eth.estimate_gas(tx)
        
        signed_txn = self.w3.eth.account.sign_transaction(tx, private_key=self.account.key)
        tx_hash = self.w3.eth.send_raw_transaction(signed_txn.rawTransaction)
        tx_receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash, timeout=120)
        
        if tx_receipt.status == 0:
            # В реальном приложении здесь должно быть логирование
            raise Exception(f"Транзакция провалена. Хэш: {tx_hash.hex()}")
        return tx_receipt

    def create_campaign(self, goal_in_eth: int | float, duration_seconds: int = 2592000) -> str:
        """
        Создает кампанию в блокчейне от имени аккаунта организации.
        Возвращает адрес созданного контракта кампании.
        """
        goal_in_wei = Web3.to_wei(goal_in_eth, 'ether')
        nonce = self.w3.eth.get_transaction_count(self.account.address)

        tx = self.registry_contract.functions.createCampaign(
            goal_in_wei,
            duration_seconds
        ).build_transaction({'nonce': nonce, 'from': self.account.address})

        receipt = self._send_transaction(tx)
        
        event_logs = self.registry_contract.events.CampaignCreated().process_receipt(receipt)
        if not event_logs:
            raise Exception("Событие CampaignCreated не найдено в логах транзакции.")
        
        campaign_address = event_logs[0]['args']['campaignAddress']
        return campaign_address

    def get_campaign_financials(self, campaign_address: str) -> dict:
        """
        Получает финансовые данные (цель, собрано) для кампании из блокчейна.
        """
        checksum_address = Web3.to_checksum_address(campaign_address)
        campaign_contract = self.w3.eth.contract(address=checksum_address, abi=self._campaign_abi)
        
        total_donated_wei = campaign_contract.functions.totalDonated().call()
        goal_wei = campaign_contract.functions.goal().call()

        return {
            "target": Web3.from_wei(goal_wei, 'ether'), 
            "collected": Web3.from_wei(total_donated_wei, 'ether'),
        }

blockchain_util = BlockchainUtil()