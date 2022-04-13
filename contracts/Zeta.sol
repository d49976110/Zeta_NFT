// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Zeta is ERC721Enumerable,Ownable {
    using Strings for uint256;

    bool public _isSaleActive = false;
    bool public _revealed = false;

    // Constants
    uint256 public constant MAX_SUPPLY = 999;
    uint256 public mintPrice = 0.03 ether;
    uint256 public accountMaxAmount = 1;
    uint256 public maxMinPerTime = 1;

    string baseURI;
    string public notRevealedUri;
    string public baseExtension = ".json";

    constructor()ERC721("ZETA_souvenir", "ZETA"){
        _mint(99);
    }

    //only owner
    function flipSaleActive() external onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() external onlyOwner {
        _revealed = !_revealed;
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory base_URI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(base_URI, tokenId.toString(),baseExtension)) : "";
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function mint(uint256 tokenQuantity) external payable {
        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Already achieve max supply"
        );
        require(_isSaleActive, "Sale must be active to mint");
        require(
            balanceOf(msg.sender) + tokenQuantity <= accountMaxAmount,
            "Up to account max amount"
        );
        require(
            tokenQuantity * mintPrice <= msg.value,
            "Not enough ether to mint"
        );
        require(tokenQuantity <= maxMinPerTime, "Over max mint per time");

        _mint(tokenQuantity);
    }

    function _mint(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }
}
