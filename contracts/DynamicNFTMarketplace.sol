// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title DynamicNFTMarketplace
 * @dev A marketplace for dynamic NFTs that can evolve over time
 */
contract DynamicNFTMarketplace is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    // Mapping from token ID to token price
    mapping(uint256 => uint256) public tokenPrices;
    
    // Mapping from token ID to token evolution stage
    mapping(uint256 => uint256) public tokenEvolutionStages;
    
    // Mapping from token ID to metadata URI for each evolution stage
    mapping(uint256 => mapping(uint256 => string)) public evolutionStageURIs;
    
    // Events
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTDelisted(uint256 indexed tokenId, address indexed owner);
    event NFTPurchased(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);
    event NFTEvolved(uint256 indexed tokenId, uint256 newStage);
    
    constructor() ERC721("DynamicNFT", "DNFT") {}
    
    /**
     * @dev Creates a new NFT with initial evolution stage and lists it for sale
     * @param initialURI The initial metadata URI for the NFT
     * @param price The listing price in wei
     * @return The ID of the newly created NFT
     */
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

    /**
     * @dev Batch mint multiple NFTs with initial URIs and prices
     * @param initialURIs Array of initial metadata URIs
     * @param prices Array of listing prices (must match initialURIs length)
     */
    function batchCreateAndListNFTs(string[] memory initialURIs, uint256[] memory prices) external {
        require(initialURIs.length == prices.length, "Mismatched inputs");
        
        for (uint256 i = 0; i < initialURIs.length; i++) {
            require(prices[i] > 0, "Price must be > 0");
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

    /**
     * @dev Allows users to purchase an NFT safely
     * @param tokenId The ID of the NFT to purchase
     */
    function purchaseNFT(uint256 tokenId) external payable nonReentrant {
        address seller = ownerOf(tokenId);
        require(seller != msg.sender, "Cannot buy your own NFT");
        uint256 price = tokenPrices[tokenId];
        require(price > 0, "NFT not for sale");
        require(msg.value >= price, "Insufficient funds");

        // Remove listing before transfer to prevent reentrancy
        delete tokenPrices[tokenId];
        
        // Transfer ownership
        _transfer(seller, msg.sender, tokenId);
        
        // Transfer funds to seller
        payable(seller).transfer(price);

        // Refund excess
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
        
        emit NFTPurchased(tokenId, seller, msg.sender, price);
    }
    
    /**
     * @dev Delist an NFT from sale
     * @param tokenId The ID of the NFT to delist
     */
    function delistNFT(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(tokenPrices[tokenId] > 0, "NFT not listed");
        
        delete tokenPrices[tokenId];
        
        emit NFTDelisted(tokenId, msg.sender);
    }
    
    /**
     * @dev Update the price of an NFT listing
     * @param tokenId The ID of the NFT
     * @param newPrice The new price in wei
     */
    function updateListingPrice(uint256 tokenId, uint256 newPrice) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(newPrice > 0, "Price must be greater than zero");
        
        tokenPrices[tokenId] = newPrice;
        
        emit NFTListed(tokenId, msg.sender, newPrice);
    }
    
    /**
     * @dev Evolves an NFT to the next stage
     * @param tokenId The ID of the NFT to evolve
     * @param newStageURI The metadata URI for the new evolution stage
     */
    function evolveNFT(uint256 tokenId, string memory newStageURI) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        
        uint256 newStage = tokenEvolutionStages[tokenId] + 1;
        
        tokenEvolutionStages[tokenId] = newStage;
        evolutionStageURIs[tokenId][newStage] = newStageURI;
        
        _setTokenURI(tokenId, newStageURI);
        
        emit NFTEvolved(tokenId, newStage);
    }

    /**
     * @dev Returns the current evolution stage of an NFT
     * @param tokenId The NFT ID
     * @return The current stage number
     */
    function getCurrentEvolutionStage(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "NFT does not exist");
        return tokenEvolutionStages[tokenId];
    }

    /**
     * @dev Returns the metadata URI of a specific evolution stage for an NFT
     * @param tokenId The NFT ID
     * @param stage The evolution stage
     * @return URI string
     */
    function getEvolutionURI(uint256 tokenId, uint256 stage) external view returns (string memory) {
        require(_exists(tokenId), "NFT does not exist");
        string memory uri = evolutionStageURIs[tokenId][stage];
        require(bytes(uri).length > 0, "URI for stage not found");
        return uri;
    }
    
    /**
     * @dev Returns the listing price of an NFT, or zero if not listed
     * @param tokenId The NFT ID
     */
    function getListingPrice(uint256 tokenId) external view returns (uint256) {
        return tokenPrices[tokenId];
    }

    /**
     * @dev Withdraw any ETH mistakenly sent to the contract
     */
    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner()).transfer(balance);
    }
}
