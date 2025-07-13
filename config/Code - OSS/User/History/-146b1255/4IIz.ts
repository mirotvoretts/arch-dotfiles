import { writeFileSync, mkdirSync, existsSync } from 'fs';
import { join } from 'path';

interface Attribute {
  trait_type: string;
  value: string;
}

interface Metadata {
  name: string;
  description: string;
  image: string;
  attributes: Attribute[];
}

const CONFIG = {
  collectionName: "Ursa Pixels",
  description: "Pixel art bears holding various drinks",
  baseImageURI: "ipfs:\/\/QmUEfFfwAh4wyB5UfHCVPUxis4j4Q4kJXtm5x5p3g1fVUn",
  outputFolder: "./metadata",
  totalSupply: 100
};

const ATTRIBUTES = {
  Clothes: [
    { name: "Jacket", probability: 45 },
    { name: "Suit", probability: 25 },
    { name: "Military", probability: 10 },
    { name: "Empty", probability: 20 }
  ],
  Hair: [
    { name: "Fade", probability: 30 },
    { name: "Mohawk", probability: 25 },
    { name: "Box", probability: 35 },
    { name: "Empty", probability: 10 }
  ],
  Boots: [
    { name: "Nike", probability: 40 },
    { name: "Adidas", probability: 20 },
    { name: "New Balance", probability: 10 },
    { name: "Empty", probability: 30 }
  ]
};

function selectRandomAttribute(options: { name: string, probability: number }[]): string {
  const total = options.reduce((sum, opt) => sum + opt.probability, 0);
  let random = Math.random() * total;
  
  for (const option of options) {
    if (random < option.probability) return option.name;
    random -= option.probability;
  }
  
  return options[0].name;
}

function formatTokenId(tokenId: number): string {
  return tokenId.toString().padStart(4, '0');
}

if (!existsSync(CONFIG.outputFolder)) {
  mkdirSync(CONFIG.outputFolder);
}

for (let tokenId = 1; tokenId <= CONFIG.totalSupply; tokenId++) {
  const formattedTokenId = formatTokenId(tokenId);
  const metadata: Metadata = {
    name: `${CONFIG.collectionName} #${tokenId}`,
    description: CONFIG.description,
    image: `${CONFIG.baseImageURI}bear-${formattedTokenId}.png`, // Изменено здесь
    attributes: [
      {
        trait_type: "Clothes",
        value: selectRandomAttribute(ATTRIBUTES.Clothes)
      },
      {
        trait_type: "Hair",
        value: selectRandomAttribute(ATTRIBUTES.Hair)
      },
      {
        trait_type: "Boots",
        value: selectRandomAttribute(ATTRIBUTES.Boots)
      }
    ]
  };

  const filename = join(CONFIG.outputFolder, `${tokenId}.json`);
  writeFileSync(filename, JSON.stringify(metadata, null, 2));
  console.log(`Generated metadata for token #${tokenId} (bear-${formattedTokenId}.png)`);
}

console.log(`Output folder: ${CONFIG.outputFolder}`);