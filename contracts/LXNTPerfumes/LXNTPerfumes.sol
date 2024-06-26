// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract LXNTPerfumes is ERC721, ERC721Royalty, ERC721Enumerable, Ownable {
    using Strings for uint256;
    AggregatorV3Interface internal priceFeed;

    uint256 public constant MAX_SUPPLY_LUXURY = 99;
    uint256 public constant MAX_SUPPLY_PREMIUM = 2999;
    uint256 public constant MAX_SUPPLY_STANDARD = 9999;

    uint256 public totalSupplyLuxury = 0;
    uint256 public totalSupplyPremium = 0;
    uint256 public totalSupplyStandard = 0;

// State variables for prices
    uint256 public priceLuxury = 9999;
    uint256 public pricePremium = 2999;
    uint256 public priceStandard = 199;

    string public baseLuxuryTokenURI =
        "https://nftstorage.link/ipfs/bafybeibw7ff3hn4uaou4yo3wmzmkagmehm4fjw2gwqh42al7xxpjdrbai4/";
    string public basePremiumTokenURI =
        "https://nftstorage.link/ipfs/bafybeiacom3gtk5s5ambbgkdlpbdyuhxyzbor57hkujayfkc6hzko2jg5a/";
    string public baseStandardTokenURI =
        "https://nftstorage.link/ipfs/bafybeibk3y2tpkestcdbedfwq7fjz6pmdk7sfgyvhvwqgiozkxxiha3pga/";

    enum SalePhase {
        PRE_SALES,
        WL_SALES,
        PUBLIC_SALES
    }

    SalePhase public currentSalePhase;

    bytes32 public merkleRoot;

    address public Luxent;
    address public Investor;
    address public Artlanta;
    address public M_S;
    address public UNITE;

    uint96 public royaltyFirstBuyer;
    uint96 public royaltyLuxent;
    uint96 public royaltyM_S;

    constructor() ERC721("LXNT Perfumes", "LXNT") {
        merkleRoot = 0x77e7f3c0746df56f023b33c94b588990b3677d86b6bd4a75220a26b17b9796d6;
        Luxent = 0x7E7eAd180512651B5999A7B4eBA03fF2fE2219D7;
        Investor = 0x640531531a95d274f8AAFf0FC970a692DE0898dB;
        Artlanta = 0x4E57735B0326E2048D0eA72242420FCFc5A1feE6;
        M_S = 0xb4646b16C6A5f1e38823B87F3C8E57E95d68897d;
        UNITE = 0xB79568F57d31b7B4C6D62971b121E6b85531D022;
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        royaltyFirstBuyer = 3;
        royaltyLuxent = 3;
        royaltyM_S = 4;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721Royalty) {
        super._burn(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Royalty, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setTokenURI(uint256 collectionId, uint256 tokenId) public view returns (string memory str) {
        _exists(tokenId);
        if (collectionId == 3) {
            return string(abi.encodePacked(baseLuxuryTokenURI, tokenId.toString(), ".json"));
        } else if (collectionId == 2) {
            return string(abi.encodePacked(basePremiumTokenURI, tokenId.toString(), ".json"));
        } else if (collectionId == 1) {
            return string(abi.encodePacked(baseStandardTokenURI, tokenId.toString(), ".json"));
        }
    }
    function mintPRE(uint256 collectionId) external payable {
        require(currentSalePhase == SalePhase.PRE_SALES, "PRE_SALES is not active");

        if (collectionId == 3) {
            require(msg.value >= getPriceRate(priceLuxury), "Ether sent is not correct");
            require(totalSupplyLuxury < ((MAX_SUPPLY_LUXURY * 15) / 100), "Max supply reached for this phase");
            totalSupplyLuxury++;
        } else if (collectionId == 2) {
            require(msg.value >= getPriceRate(pricePremium), "Ether sent is not correct");
            require(totalSupplyPremium < ((MAX_SUPPLY_PREMIUM * 15) / 100), "Max supply reached for this phase");
            totalSupplyPremium++;
        } else if (collectionId == 1) {
            require(msg.value >= getPriceRate(priceStandard), "Ether sent is not correct");
            require(totalSupplyStandard < ((MAX_SUPPLY_STANDARD * 15) / 100), "Max supply reached for this phase");
            totalSupplyStandard++;
        } else {
            revert("Invalid collection ID");
        }
        profitSplit(collectionId);

        // Transfer 41.5% of the balance to Luxent
        payable(Luxent).transfer(msg.value * 83 / 200);
        // Transfer 10% of the balance to Investor
        payable(Investor).transfer(msg.value / 10);
        // Transfer 5% of the balance to Artlanta
        payable(Artlanta).transfer(msg.value / 20);
        // Transfer 41.5% of the balance to M_S
        payable(M_S).transfer(msg.value * 83 / 200);
        // Transfer 2% of the balance to UNITE
        payable(UNITE).transfer(msg.value / 50);
    }

    function mintWL(bytes32[] calldata _merkleProof, uint256 collectionId) external payable {
        require(currentSalePhase == SalePhase.WL_SALES, "WL_SALES is not active");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid proof");

        if (collectionId == 3) {
            require(msg.value >= getPriceRate(priceLuxury), "Ether sent is not correct");
            require(totalSupplyLuxury < ((MAX_SUPPLY_LUXURY * 50) / 100), "Max supply reached for this phase");
            totalSupplyLuxury++;
        } else if (collectionId == 2) {
            require(msg.value >= getPriceRate(pricePremium), "Ether sent is not correct");
            require(totalSupplyPremium < ((MAX_SUPPLY_PREMIUM * 50) / 100), "Max supply reached for this phase");
            totalSupplyPremium++;
        } else if (collectionId == 1) {
            require(msg.value >= getPriceRate(priceStandard), "Ether sent is not correct");
            require(totalSupplyStandard < ((MAX_SUPPLY_STANDARD * 50) / 100), "Max supply reached for this phase");
            totalSupplyStandard++;
        } else {
            revert("Invalid collection ID");
        }
        profitSplit(collectionId);

        // Transfer 41.5% of the balance to Luxent
        payable(Luxent).transfer(msg.value * 83 / 200);
        // Transfer 10% of the balance to Investor
        payable(Investor).transfer(msg.value / 10);
        // Transfer 5% of the balance to Artlanta
        payable(Artlanta).transfer(msg.value / 20);
        // Transfer 41.5% of the balance to M_S
        payable(M_S).transfer(msg.value * 83 / 200);
        // Transfer 2% of the balance to UNITE
        payable(UNITE).transfer(msg.value / 50);
    }

    function mintPUBLIC(uint256 collectionId) external payable {
        require(currentSalePhase == SalePhase.PUBLIC_SALES, "PUBLIC_SALES is not active");

        if (collectionId == 3) {
            require(msg.value >= getPriceRate(priceLuxury), "Ether sent is not correct");
            require(totalSupplyLuxury < MAX_SUPPLY_LUXURY, "Max supply reached for this phase");
            totalSupplyLuxury++;
        } else if (collectionId == 2) {
            require(msg.value >= getPriceRate(pricePremium), "Ether sent is not correct");
            require(totalSupplyPremium < MAX_SUPPLY_PREMIUM, "Max supply reached for this phase");
            totalSupplyPremium++;
        } else if (collectionId == 1) {
            require(msg.value >= getPriceRate(priceStandard), "Ether sent is not correct");
            require(totalSupplyStandard < MAX_SUPPLY_STANDARD, "Max supply reached for this phase");
            totalSupplyStandard++;
        } else {
            revert("Invalid collection ID");
        }
        profitSplit(collectionId);

        // Transfer 41.5% of the balance to Luxent
        payable(Luxent).transfer(msg.value * 83 / 200);
        // Transfer 10% of the balance to Investor
        payable(Investor).transfer(msg.value / 10);
        // Transfer 5% of the balance to Artlanta
        payable(Artlanta).transfer(msg.value / 20);
        // Transfer 41.5% of the balance to M_S
        payable(M_S).transfer(msg.value * 83 / 200);
        // Transfer 2% of the balance to UNITE
        payable(UNITE).transfer(msg.value / 50);
    }

    function crossmint(uint256 collectionId, address recipient, uint256 number) external payable {
        require(currentSalePhase != SalePhase.WL_SALES, "You can't call crossmint in WL phase.");
        require(number == 1, "You can mint only 1 NFT per call.");
        require(collectionId == 1, "Crossmint is allowed for only Elegant Collection.");
        require(msg.value >= getPriceRate(priceStandard), "Ether sent is not correct.");
        require(totalSupplyStandard < MAX_SUPPLY_STANDARD, "Max supply reached for this phase.");

        totalSupplyStandard++;

        uint256 tokenId = _getNextTokenId(collectionId);
        _safeMint(recipient, tokenId);
        setTokenURI(collectionId, tokenId);

        _setTokenRoyalty(tokenId, msg.sender, royaltyFirstBuyer);
        _setTokenRoyalty(tokenId, Luxent, royaltyLuxent);
        _setTokenRoyalty(tokenId, M_S, royaltyM_S);

        // Transfer 41.5% of the balance to Luxent
        payable(Luxent).transfer(msg.value * 83 / 200);
        // Transfer 10% of the balance to Investor
        payable(Investor).transfer(msg.value / 10);
        // Transfer 5% of the balance to Artlanta
        payable(Artlanta).transfer(msg.value / 20);
        // Transfer 41.5% of the balance to M_S
        payable(M_S).transfer(msg.value * 83 / 200);
        // Transfer 2% of the balance to UNITE
        payable(UNITE).transfer(msg.value / 50);
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setLuxent(address addr) external onlyOwner {
        Luxent = addr;
    }

    function setInvestor(address addr) external onlyOwner {
        Investor = addr;
    }

    function setArtlanta(address addr) external onlyOwner {
        Artlanta = addr;
    }

    function setM_S(address addr) external onlyOwner {
        M_S = addr;
    }

    function setUNITE(address addr) external onlyOwner {
        UNITE = addr;
    }

    function setRoyalty(uint96 frag1, uint96 frag2, uint96 frag3) external onlyOwner {
        royaltyFirstBuyer = frag1;
        royaltyLuxent = frag2;
        royaltyM_S = frag3;
    }

    function getPriceRate(uint _amount) public view returns (uint) {
        // (, int256 price, , , ) = priceFeed.latestRoundData();
        int256 price = 100000000000000;
        uint adjust_price = uint(price) * 1e10;
        uint usd = _amount * 1e18;
        uint rate = (usd * 1e18) / adjust_price;
        return rate;
    }

    function _withdraw(address target, uint256 balance) public onlyOwner {
        payable(target).transfer(balance);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;

        // Transfer 41.5% of the balance to Luxent
        _withdraw(Luxent, (balance * 83) / 200);

        // Transfer 10% of the balance to Investor
        _withdraw(Investor, balance / 10);

        // Transfer 5% of the balance to Artlanta
        _withdraw(Artlanta, balance / 20);

        // Transfer 41.5% of the balance to M_S
        _withdraw(M_S, (balance * 83) / 200);

        // Transfer 2% of the balance to UNITE
        _withdraw(UNITE, balance / 50);
    }

    function profitSplit(uint256 collectionId) internal{
        uint256 tokenId = _getNextTokenId(collectionId);
        _safeMint(msg.sender, tokenId);
        setTokenURI(collectionId, tokenId);

        _setTokenRoyalty(tokenId, msg.sender, royaltyFirstBuyer);
        _setTokenRoyalty(tokenId, Luxent, royaltyLuxent);
        _setTokenRoyalty(tokenId, M_S, royaltyM_S);
    }

//  Setter functions for Base Token URI per Collection
    function setBaseLuxuryTokenURI(string calldata _tokenURI) external onlyOwner {
        baseLuxuryTokenURI  = _tokenURI;
    }

    function setBasePremiumTokenURI(string calldata _tokenURI) external onlyOwner {
        basePremiumTokenURI  = _tokenURI;
    }

    function setBaseStandardTokenURI(string calldata _tokenURI)external onlyOwner {
        baseStandardTokenURI  = _tokenURI;
    }

//  Setter functions for sale phases
    function startPresale() external onlyOwner {
        currentSalePhase = SalePhase.PRE_SALES;
    }

    function startWLsale() external onlyOwner {
        currentSalePhase = SalePhase.WL_SALES;
    }

    function startPublicSale() external onlyOwner {
        currentSalePhase = SalePhase.PUBLIC_SALES;
    }

 // Setter functions for prices
    function setPriceLuxury(uint256 _price) external onlyOwner {
        priceLuxury = _price;
    }

    function setPricePremium(uint256 _price) external onlyOwner {
        pricePremium = _price;
    }

    function setPriceStandard(uint256 _price) external onlyOwner {
        priceStandard = _price;
    }

    function _getNextTokenId(uint256 collectionId) private view returns (uint256) {
        if (collectionId == 3) {
            return 1 + totalSupplyLuxury;
        } else if (collectionId == 2) {
            return 100 + totalSupplyPremium;
        } else if (collectionId == 1) {
            return 3099 + totalSupplyStandard;
        } else {
            revert("Invalid collection ID");
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        
        if (tokenId <= 100) {
            return string(abi.encodePacked(baseLuxuryTokenURI, tokenId.toString(), ".json"));
        } else if (tokenId <= 3099) {
            return string(abi.encodePacked(basePremiumTokenURI, tokenId.toString(), ".json"));
        } else {
            return string(abi.encodePacked(baseStandardTokenURI, tokenId.toString(), ".json"));
        }
    }
}