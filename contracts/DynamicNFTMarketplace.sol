// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
/**
 * @title DynamicNFTMarketplace
 * @dev A marketplace for dynamic NFTs that evolve through stag
    // Mapping from token ID to stage => URI
    mapping(uint256 => mapping(uint256 => string)) public evolutionStageURIs;

    // Events
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTDelisted(uint256 indexed tokenId, address indexed owner);
    event NFTPurchased(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);
    event NFTEvolved(uint256 indexed tokenId, uint256 newStage);
    event NFTRelisted(uint256 indexed tokenId, uint256 
    event NFTBurned(uint256 indexed tokenId, address indexed owner);

    constructor() ERC721("DynamicNFT", "DNFT") {}

    // Create and list a new NFT
    function createAndListNFT(string memory initialURI, uint256 price) external returns (uint256) {
        require(price > 0, "Price must be greater than zero");

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, initialURI);

        tokenEvolutionStages[newTokenId] = 1;
        evolutionStageURIs[newTokenId][1] = initialURI;
        tokenPrices[newTokenId] = price;

        emit NFTListed(newTokenId, msg.sender, price);
        return newTokenId;
    }
// Create and list a new NFT
    function createAndListNFT(string memory initialURI, uint256 price) external returns (uint256) {
        require(price > 0, "Price must be greater than zero");

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, initialURI);

        tokenEvolutionStages[newTokenId] = 1;
        evolutionStageURIs[newTokenId][1] = initialURI;
        tokenPrices[newTokenId] = price;

        emit NFTListed(newTokenId, msg.sender, price);
        return newTokenId;
    }// Create and list a new NFT
    function createAndListNFT(string memory initialURI, uint256 price) external returns (uint256) {
        require(price > 0, "Price must be greater than zero");

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, initialURI);

        tokenEvolutionStages[newTokenId] = 1;
        evolutionStageURIs[newTokenId][1] = initialURI;
        tokenPrices[newTokenId] = price;

        emit NFTListed(newTokenId, msg.sender, price);
        return newTokenId;
    }// Create and list a new NFT
    function createAndListNFT(string memory initialURI, uint256 price) external returns (uint256) {
        require(price > 0, "Price must be greater than zero");

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
 _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, initialURI);

        tokenEvolutionStages[newTokenId] = 1;
        evolutionStageURIs[newTokenId][1] = initialURI;
        tokenPrices[newTokenId] = price;

        emit NFTListed(newTokenId, msg.sender, price);
        return newTokenId;
    }
    // Batch create and list NFTs
    function batchCreateAndListNFTs(string[] memory initialURIs, uint256[] memory prices) external {
        require(initialURIs.length == prices.length, "Mismatched inputs");

        for (uint256 i = 0; i < initialURIs.length; i++) {
            require(prices[i] > 0, "Price must be greater than zero");

            _tokenIds.increment();
            uint256 newTokenId = _tokenIds.current();

            _mint(msg.sender, newTokenId);
            _setTokenURI(newTokenId, initialURIs[i]);

            tokenEvolutionStages[newTokenId] = 1;
            evolutionStageURIs[newTokenId][1] = initialURIs[i];
            tokenPrices[newTokenId] = prices[i];

            emit NFTListed(newTokenId, msg.sender, prices[i]);
        }
    }

    // Purchase an NFT
    function purchaseNFT(uint256 tokenId) external payable nonReentrant {
        address seller = ownerOf(tokenId);
        require(seller != msg.sender, "Cannot buy your own NFT");

        uint256 price = tokenPrices[tokenId];
        require(price > 0, "NFT not for sale");
        require(msg.value >= price, "Insufficient funds");

        delete tokenPrices[tokenId];
        _transfer(seller, msg.sender, tokenId);

        payable(seller).transfer(price);

        // Refund excess
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }

        emit NFTPurchased(tokenId, seller, msg.sender, price);
    }

    // Delist an NFT
    function delistNFT(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(tokenPrices[tokenId] > 0, "NFT not listed");

        delete tokenPrices[tokenId];
        emit NFTDelisted(tokenId, msg.sender);
    }

    // Update listing price
    function updateListingPrice(uint256 tokenId, uint256 newPrice) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(newPrice > 0, "Price must be greater than zero");

        tokenPrices[tokenId] = newPrice;
        emit NFTListed(tokenId, msg.sender, newPrice);
    }

    // Relist an NFT
    function relistNFT(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(price > 0, "Price must be greater than zero");

        tokenPrices[tokenId] = price;
        emit NFTRelisted(tokenId, price);
    }

    // Evolve an NFT to a new stage
    function evolveNFT(uint256 tokenId, string memory newStageURI) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");

        uint256 newStage = tokenEvolutionStages[tokenId] + 1;
        tokenEvolutionStages[tokenId] = newStage;
        evolutionStageURIs[tokenId][newStage] = newStageURI;

        _setTokenURI(tokenId, newStageURI);
        emit NFTEvolved(tokenId, newStage);
    }

    // Burn an NFT
    function burnNFT(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");

        _burn(tokenId);

        delete tokenPrices[tokenId];
        delete tokenEvolutionStages[tokenId];

        emit NFTBurned(tokenId, msg.sender);
    }

    // Get current evolution stage
    function getCurrentEvolutionStage(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "NFT does not exist");
        return tokenEvolutionStages[tokenId];
    }

    // Get URI of specific evolution stage
    function getEvolutionURI(uint256 tokenId, uint256 stage) external view returns (string memory) {
        require(_exists(tokenId), "NFT does not exist");
        string memory uri = evolutionStageURIs[tokenId][stage];
        require(bytes(uri).length > 0, "URI for stage not found");
        return uri;
    }

    // Get listing price
    function getListingPrice(uint256 tokenId) external view returns (uint256) {
        return tokenPrices[tokenId];
    }

    // Withdraw funds from contract (owner only)
    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner()).transfer(balance);
    }

    // Get all NFTs owned by a user
    function getOwnedNFTs(address user) external view returns (uint256[] memory) {
        uint256 total = _tokenIds.current();
        uint256 count;

        for (uint256 i = 1; i <= total; i++) {
            if (_exists(i) && ownerOf(i) == user) {
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        uint256 idx = 0;

        for (uint256 i = 1; i <= total; i++) {
            if (_exists(i) && ownerOf(i) == user) {
                result[idx++] = i;
            }
        }

        return result;
    }

    // Get all listed NFTs and their prices
    function getAllListedNFTs() external view returns (uint256[] memory, uint256[] memory) {
        uint256 total = _tokenIds.current();
        uint256 count;

        for (uint256 i = 1; i <= total; i++) {
            if (_exists(i) && tokenPrices[i] > 0) {
                count++;
            }
        }

        uint256[] memory ids = new uint256[](count);
        uint256[] memory prices = new uint256[](count);
        uint256 idx = 0;

        for (uint256 i = 1; i <= total; i++) {
            if (_exists(i) && tokenPrices[i] > 0) {
                ids[idx] = i;
                prices[idx] = tokenPrices[i];
                idx++;
            }
        }

        return (ids, prices);
    }
}
