// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Zeta is ERC721Enumerable,Ownable,Pausable {
    using Strings for uint256;

    //period 2022/5/1 ~ 2022/5/7
    uint256 start_time = 1651334400 ; 
    uint256 end_time = 1651939199 ;  

    //active selling & reveal
    bool _isSaleActive = false;

    // Constants
    uint256 constant max_supply = 999;
    uint256 mintPrice = 0.001 ether;

    string baseURI;
    string notRevealedUri;
    string baseExtension = ".json";
    uint256 total_supply = 0 ;

    mapping(address=>bool) whiteList ; 

    constructor()ERC721("ZETA_Souvenir", "ZETA"){
    }

    //owner control
    function addToWhitelist(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            whiteList[users[i]] = true;
        }
    }

    function flipSaleActive() external onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function setTime(uint _startTime , uint _endTime) external onlyOwner{
        start_time = _startTime ; 
        end_time = _endTime ; 
    }

    function pause() external onlyOwner(){
        _pause();
    }

    function unpause() external onlyOwner(){
        _unpause();
    }

    function init_mint(uint _uint) external onlyOwner{
        _mint(_uint);
    }

    function withdrawBalance(uint256 amount) external onlyOwner{
        address owner = owner();
        payable(owner).transfer(amount);
    }

    //info
    function checkWhiteList(address _address) external view returns(bool){
        return whiteList[_address];
    }

    function getTime() external view returns(uint _startTime , uint _endTime){
        return (start_time , end_time) ; 
    }

    function getSaleActive() external view returns(bool){
        return _isSaleActive ; 
    }

    function getRestSupply() external view returns(uint){
        uint256 recentSupply = total_supply;
        return max_supply - recentSupply ; 
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

    //mint
    function mint(uint256 tokenQuantity) external payable whenNotPaused{
        require(whiteList[msg.sender] == true , "Not in the white list");
        require(block.timestamp >= start_time && block.timestamp <= end_time , "Not in the mint period");
        require(
            total_supply + tokenQuantity <= max_supply,
            "Already achieve max supply"
        );
        require(_isSaleActive, "Sale must be active to mint");
        require(
            tokenQuantity * mintPrice <= msg.value,
            "Not enough ether to mint"
        );

        _mint(tokenQuantity);
    }

    function _mint(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint256 mintIndex = total_supply;
            if (total_supply < max_supply) {
                _safeMint(msg.sender, mintIndex);
                total_supply ++ ; 
            }
        }
    }

    

    

    
}
