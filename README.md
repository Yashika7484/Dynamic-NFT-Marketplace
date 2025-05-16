Installation

Clone the repository:

git clone https://github.com/yourusername/dynamic-nft-marketplace.git
cd dynamic-nft-marketplace

Install dependencies:

npm install

Create a .env file with the following variables:

PRIVATE_KEY=your_private_key_here
CORE_TESTNET_URL=https://rpc.test2.btcs.network

Compile the contracts:

npx hardhat compile

Deploy to Core Testnet 2:

npx hardhat run scripts/deploy.js --network coreTestnet

Contract Address:
0x84d504becB14978CE5F83bC4b170D6c03033F9CE

![image](https://github.com/user-attachments/assets/eda02d31-578d-4ab7-97b3-ce77924dd553)
