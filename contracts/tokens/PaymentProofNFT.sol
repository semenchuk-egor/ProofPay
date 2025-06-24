// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract PaymentProofNFT is 
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    uint256 private _nextTokenId;
    mapping(uint256 => bytes32) public tokenAttestations;
    mapping(uint256 => uint256) public paymentAmounts;
    
    event ProofMinted(uint256 indexed tokenId, address indexed recipient, bytes32 attestationUID);

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __ERC721_init("PaymentProof", "PPROOF");
        __ERC721URIStorage_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        _nextTokenId = 1;
    }

    function mint(address to, bytes32 attestationUID, uint256 amount) external onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        tokenAttestations[tokenId] = attestationUID;
        paymentAmounts[tokenId] = amount;
        emit ProofMinted(tokenId, to, attestationUID);
        return tokenId;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
