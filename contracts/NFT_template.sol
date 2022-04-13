// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract NFT_template is ERC721Enumerable,Ownable,Pausable {
    using Strings for uint256;

    //period
    uint256 start_time ; 
    uint256 end_time ;  

    //active selling & reveal
    bool _isSaleActive = false;
    bool _revealed = false;

    // Constants
    uint256 constant MAX_SUPPLY = 999;
    uint256 mintPrice = 0.01 ether;
    uint256 accountMaxAmount = 1;
    uint256 maxMinPerTime = 1;

    string baseURI;
    string notRevealedUri;
    string baseExtension = ".json";

    constructor()ERC721("ZETA_Souvenir", "ZETA"){
        _mint(99);
    }

    //only owner
    function flipSaleActive() external onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() external onlyOwner {
        _revealed = !_revealed;
    }

    function setTime(uint _startTime , uint _endTime) external onlyOwner{
        start_time = _startTime ; 
        end_time = _endTime ; 
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        if (_revealed == false) {
            return notRevealedUri;
        }
        
        string memory base_URI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(base_URI, tokenId.toString(),baseExtension)) : "";
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }
    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function mint(uint256 tokenQuantity) external payable whenNotPaused{
        require(block.timestamp >= start_time && block.timestamp <= end_time , "Not in the mint period ");
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

    function withdrawBalance(uint256 amount) external onlyOwner{
        address owner = owner();
        payable(owner).transfer(amount);
    }

    function checkBalance() external view returns(uint) {
        return address(this).balance;
    }

    function getTime() external view returns(uint){
        return block.timestamp ; 
    }
}
