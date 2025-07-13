from blockchain import BlockchainUtil

def test_blockchain_util():
    # 1. Проверка подключения
    util = BlockchainUtil()
    util.init()  # Вызов init вручную (если не в __init__)
    print("✅ Подключение к ноде успешно")

    # 2. Создание кампании
    campaign_address = util.create_campaign(goal_in_eth=5.0)  # Цель: 5 ETH
    print(f"✅ Кампания создана. Адрес: {campaign_address}")

    # 3. Проверка данных кампании
    financials = util.get_campaign_financials(campaign_address)
    print(f"Данные кампании: {financials}")

if __name__ == "__main__":
    test_blockchain_util()