# Ursa Pixels :: NFT Collection  
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](https://opensource.org/licenses/MIT)  
[![Solidity](https://img.shields.io/badge/Solidity-363636?style=for-the-badge&logo=solidity&logoColor=white)](https://soliditylang.org/)  
[![Foundry](https://img.shields.io/badge/Foundry-F76802?style=for-the-badge&logo=ethereum&logoColor=white)](https://getfoundry.sh/)  
[![Ethereum](https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=ethereum&logoColor=white)](https://ethereum.org/)  
[![IPFS](https://img.shields.io/badge/IPFS-65C2CB?style=for-the-badge&logo=ipfs&logoColor=white)](https://ipfs.tech/)  
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-4E5EE4?style=for-the-badge&logo=OpenZeppelin&logoColor=white)](https://openzeppelin.com/)  

A collection of pixelated bears implemented using the **ERC721** standard.

---

## Technical Details

- **Standard**: ERC721  
- **Blockchain**: Ethereum (Sepolia testnet)  
- **Language**: Solidity 0.8.28  
- **Framework**: Foundry  
- **Libraries**: OpenZeppelin Contracts  
- **Contract Address**: [`0xd92571bf259c5db67bc85a52f90ccfbd15730cfe`](https://sepolia.etherscan.io/address/0xd92571bf259c5db67bc85a52f90ccfbd15730cfe)

---

## Features

### Core Functions

- `mint(uint256 amount, address recipient)` – mint new NFTs  
  - Price: 0.001 ETH per token  
  - Limits:  
    - Max 3 tokens per transaction  
    - Max 6 tokens per wallet  
    - Total supply: 100 tokens  

- `withdraw(uint256 amount, address payable recipient)` – withdraw funds  
  - Only callable by the contract owner

---

### NFT Attributes (randomly generated)

| Category   | Variants (probability)                               |
|------------|-------------------------------------------------------|
| Clothes    | Jacket (45%), Suit (25%), Military (10%), Empty (20%)|
| Hair       | Fade (30%), Mohawk (25%), Box (35%), Empty (10%)     |
| Boots      | Nike (40%), Adidas (20%), New Balance (10%), Empty (30%)|

---

## Installation and Setup

1. Clone the repository:

```bash
git clone git@github.com:mirotvoretts/nft_erc721_collection.git
cd nft_erc721_collection
```

2. Install dependencies:

```bash
forge install
npm install @pinata/sdk
```

3. Generate metadata:
   
```bash
ts-node script/GenerateMetadata.ts
```

> Next, upload the metadata to IPFS and deploy the contract.I used  [Pinata](https://app.pinata.cloud/), деплой делал через [Remix](https://remix.ethereum.org/) (flatten делал тоже в Remix)

## Тестирование

```bash
forge test
```

#### Покрытие тестами:

- Минтинг токенов
- Проверка лимитов
- Тесты withdraw

## Ссылки
- Изображения: [IPFS](https://ipfs.io/ipfs/Qmb8Guy7sL3i3GWKxaP62m98r8FgMQYoxnpapTmotCDzu1)
- Метаданные: [IPFS](https://ipfs.io/ipfs/bafybeib4ddjm7xerztvbiifcrhsfraw45zosc5czckrxipvunkyjha2y6q/)
