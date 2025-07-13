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
  baseImageURI: "ipfs://Qmb8Guy7sL3i3GWKxaP62m98r8FgMQYoxnpapTmotCDzu1/",
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

if (!existsSync(CONFIG.outputFolder)) {
  mkdirSync(CONFIG.outputFolder);
}

for (let tokenId = 1; tokenId <= CONFIG.totalSupply; tokenId++) {
  const metadata: Metadata = {
    name: `${CONFIG.collectionName} #${tokenId}`,
    description: CONFIG.description,
    image: `${CONFIG.baseImageURI}${tokenId}.png`, // Предполагается формат 1.png, 2.png и т.д.
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
  console.log(`Generated metadata for token #${tokenId}`);
}

console.log(`Output folder: ${CONFIG.outputFolder}`);
