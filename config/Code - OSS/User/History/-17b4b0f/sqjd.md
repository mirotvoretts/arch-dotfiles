Ursa Pixels :: NFT Collection
License
Solidity
Foundry
Ethereum
IPFS
OpenZeppelin

A collection of pixel bears implemented using the ERC721 standard

Technical Specifications
Standard: ERC721

Blockchain: Ethereum (Sepolia testnet)

Language: Solidity 0.8.28

Framework: Foundry

Libraries: OpenZeppelin Contracts

Contract: 0xd92571bf259c5db67bc85a52f90ccfbd15730cfe

Features
Core Functions
mint(uint256 amount, address recipient) - NFT creation

Price: 0.001 ETH per token

Limits:

Max 3 tokens per transaction

Max 6 tokens per wallet

Total supply: 100 tokens

withdraw(uint256 amount, address payable recipient) - funds withdrawal

Only contract owner can call

NFT Attributes (randomly generated)
Category	Options (probability)
Clothes	Jacket (45%), Suit (25%), Military (10%), Empty (20%)
Hair	Fade (30%), Mohawk (25%), Box (35%), Empty (10%)
Boots	Nike (40%), Adidas (20%), New Balance (10%), Empty (30%)
Setup & Deployment
Clone the repository:

bash
git clone git@github.com:mirotvoretts/nft_erc721_collection.git
cd nft_erc721_collection
Install dependencies:

bash
forge install
npm install @pinata/sdk
Generate metadata:

bash
ts-node script/GenerateMetadata.ts
Next, upload metadata to IPFS and deploy. I used Pinata for metadata upload and Remix for deployment (flattening was also done in Remix)

Testing
bash
forge test
Test Coverage:
Token minting

Limit validations

Withdraw tests

Links
Images: IPFS

Metadata: IPFS