// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.3/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.7.3/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.3/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts@4.7.3/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts@4.7.3/token/ERC20/extensions/draft-ERC20Permit.sol";

contract FracToken is ERC20, Ownable, ERC721Holder, ERC20Permit {
    constructor() ERC20("FracToken", "FTK") ERC20Permit("FracToken") {}
    IERC721 public collection;  //NFT address to be fractionalized
    uint256 public tokenId;    //Token Id of the NFT
    bool public initialized = false;    //To check if the collection already fractionalized
    bool public forSale = false;    //To mark NFT for sale
    bool public redeemable = false; //To check redeem available
    uint256 public salePrice;   //NFT sale price

    //Initiating Fractionalizing

    function initialization(address _collection, uint256 _tokenId, uint256 _amount) external onlyOwner {
        require(!initialized, "Fraction already initialized");
        require(_amount > 0, "Entered amount is incorrect");
        collection = IERC721(_collection);
        collection.safeTransferFrom(msg.sender, address(this), _tokenId);
        tokenId = _tokenId;
        initialized = true;
        _mint(msg.sender, _amount);     
    }


    //Marking NFT for sale

    function putForSale(uint256 price) external onlyOwner{
        salePrice = price;
        forSale = true;
    }


    //Allowing user to buy the NFT

    function purchase() external payable {
        require(forSale, "Not available for sale");
        require(msg.value >= salePrice, "Not enough amount of ether sent");
        collection.transferFrom(address(this), msg.sender, tokenId);
        forSale = false;
        redeemable = true;
    }

    //Redeem the ether after NFT sell

    function redeem(uint256 _amount) external {
        require(redeemable, "Cannot redeem");
        uint256 totalBalance = address(this).balance;
        uint256 toRedeem = _amount * totalBalance / totalSupply();

        _burn(msg.sender, _amount);  //burn function will also check if the amount is available
        payable(msg.sender).transfer(toRedeem);
    }

}
