const hre = require("hardhat");

async function main() {
  const [owner, organization, donor] = await hre.ethers.getSigners();

  console.log("Owner address:", owner.address);
  console.log("Organization address:", organization.address);
  console.log("Donor address:", donor.address);

  // Подключаемся к PlatformRegistry
  const registry = await hre.ethers.getContractAt(
    "PlatformRegistry",
    "0x5FbDB2315678afecb367f032d93F642f64180aa3"
  );

  // 1. Верифицируем организацию (если ещё не верифицирована)
  try {
    const isVerified = await registry.verifiedOrgranizations(organization.address);
    if (!isVerified) {
      const tx = await registry.connect(owner).verify(organization.address, true);
      await tx.wait();
      console.log(`✅ Организация ${organization.address} успешно верифицирована`);
    } else {
      console.log(`ℹ️ Организация ${organization.address} уже верифицирована`);
    }
  } catch (error) {
    console.error("❌ Ошибка при верификации:", error.reason || error.message);
    process.exit(1);
  }

  // 2. Создаем новую кампанию
  console.log("\n⏳ Создаем новую кампанию...");
  const goal = hre.ethers.utils.parseEther("5"); // цель: 5 ETH
  const deadline = Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60; // срок: 30 дней

  const createCampaignTx = await registry.connect(organization).createCampaign(goal, deadline);
  const receipt = await createCampaignTx.wait();

  // Извлекаем адрес кампании из события CampaignCreated
  const campaignEvent = receipt.events.find((e) => e.event === "CampaignCreated");
  if (!campaignEvent) {
    throw new Error("❌ Не найдено событие CampaignCreated в транзакции");
  }

  const campaignAddress = campaignEvent.args._campaignAddress;
  console.log(`✅ Кампания создана по адресу: ${campaignAddress}`);

  // 3. Подключаемся к CharityCampaign
  const CharityCampaign = await hre.ethers.getContractFactory("CharityCampaign");
  const campaign = CharityCampaign.attach(campaignAddress);

  // 4. Делаем пожертвование от донора
  console.log("\n💸 Делаем пожертвование от донора...");
  const donateTx = await campaign.connect(donor).donate({
    value: hre.ethers.utils.parseEther("1"),
  });
  await donateTx.wait();
  console.log(`✅ Донор ${donor.address} пожертвовал 1 ETH`);

  // 5. Проверяем статус кампании
  console.log("\n📊 Проверяем статус кампании...");
  const status = await campaign.getStatus();
  console.log(`📌 Статус кампании: ${status}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Ошибка:", error);
    process.exit(1);
  });