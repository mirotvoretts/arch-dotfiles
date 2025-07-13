const hre = require('hardhat');

async function main() {
    const [owner, organization, donor] = await hre.ethers.getSigners()

    console.log('Owner address:', owner.address)
    console.log('Organization address:', organization.address)
    console.log('Donor address:', donor.address)

    // Подключаемся к PlatformRegistry
    const registry = await hre.ethers.getContractAt(
        'PlatformRegistry',
        '0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1'
    )

    // 1. Проверяем верификацию организации
    const isVerified = await registry.verifiedOrganizations(organization.address)
    if (!isVerified) {
        console.log('ℹ️ Организация не верифицирована. Верифицируем...')
        const tx = await registry.connect(owner).verify(organization.address, true)
        await tx.wait()
        console.log(`✅ Организация ${organization.address} успешно верифицирована`)
    } else {
        console.log(`ℹ️ Организация ${organization.address} уже верифицирована`)
    }

    // 2. Создаём новую кампанию
    console.log('\n⏳ Создаем новую кампанию...')
    const goal = 50000000
    const deadline = Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60 // 30 дней

    // Создаем кампанию и получаем адрес из возвращаемого значения
    const createCampaignTx = await registry
        .connect(organization)
        .createCampaign(goal, deadline)
    
    // Ждем подтверждения транзакции
    const receipt = await createCampaignTx.wait()
    
    // Получаем адрес кампании из события
    const event = receipt.events.find(e => e.event === "CampaignCreated")
    const campaignAddress = event.args._campaignAddress
    
    console.log(`✅ Кампания создана по транзакции: ${createCampaignTx.hash}`)
    console.log(`📌 Адрес кампании: ${campaignAddress}`)

    // 3. Подключаемся к CharityCampaign
    const CharityCampaign = await hre.ethers.getContractFactory('CharityCampaign')
    const campaign = CharityCampaign.attach(campaignAddress)

    // 4. Делаем пожертвование от донора
    console.log('\n💸 Делаем пожертвование от донора...')
    const donateTx = await campaign.connect(donor).donate({
        value: hre.ethers.utils.parseEther('1'),
    })
    await donateTx.wait()
    console.log(`✅ Донор ${donor.address} пожертвовал 1 ETH`)

    // 5. Проверяем статус кампании
    console.log('\n📊 Проверяем статус кампании...')
    const status = await campaign.getStatus()
    console.log(`📌 Статус кампании: ${status}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error('❌ Ошибка:', error)
        process.exit(1)
    })