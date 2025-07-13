// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyNFTCollection is ERC721, Ownable {
    error InvalidAmount();
    error ExceedsMaxSupply();
    error IncorrectETHValue();
    error ExceedsWalletLimit();
    error TransferFailed();
    error ZeroAddress();

    uint256 private _nextTokenId = 1;
    
    uint256 public immutable MAX_SUPPLY;
    uint256 public constant MINT_PRICE = 0.001 ether;
    uint256 public constant MAX_PER_TX = 3;
    uint256 public constant MAX_PER_WALLET = 6;

    mapping(address => uint256) public mintCount;

    constructor(
        address initialOwner,
        uint256 maxSupply
    ) ERC721("UrsaPixels", "URPX") Ownable(initialOwner) {
        MAX_SUPPLY = maxSupply;
    }

    function _baseURI() internal pure override returns (string memory) {
        return
            "ipfs://bafybeiaxgymouylj3cln37payudjatwxejz4wziawdighnrpujahaerlya/";
    }

    function tokenURI(
        uint256 tokenId
    ) public pure override returns (string memory) {
        return
            string(
                abi.encodePacked(_baseURI(), Strings.toString(tokenId), ".json")
            );
    }

    function _validateMint(uint256 amount, address recipient) internal {
        if (amount == 0 || amount > MAX_PER_TX) revert InvalidAmount();
        if (mintCount[recipient] + amount > MAX_PER_WALLET)
            revert ExceedsWalletLimit();
        if (_nextTokenId + amount > MAX_SUPPLY) revert ExceedsMaxSupply();
        if (msg.value != amount * MINT_PRICE) revert IncorrectETHValue();
    }

    function mint(uint256 amount, address recipient) external payable {
        _validateMint(amount, recipient);
        mintCount[recipient] += amount;
        for (uint256 i = 0; i < amount; i++) {
            _safeMint(recipient, _nextTokenId++);
        }
    }

    function withdraw(
        uint256 amount,
        address payable recipient
    ) external onlyOwner {
        require(0 < amount && amount <= address(this).balance, InvalidAmount());
        require(recipient != address(0), ZeroAddress());
        (bool success, ) = recipient.call{value: amount}("");
        require(success, TransferFailed());
    }

    function totalSupply() external view returns (uint256) {
        return _nextTokenId - 1;
    }
}
