pragma solidity ^0.5.0;

import "./Auction.sol";
import "./nft-contract.sol";

contract AuctionDaddy {

    Auction[] auctions;
    MintableToken nftContract;

    constructor (address nftContract) public {
        this.nftContract = nftContract;
    }

    function createNewAuction(uint256 endBlock, uint256 reserve, uint256 tokenId, uint256 startingBid) public {
        require(msg.sender == nftContract.ownerOf(tokenId), "You must be the owner of an NFT to sell that NFT");
        require(endBlock - block.number < 100, "Auction will end too soon");

        Auction newAuction = new Auction(msg.sender, startingBid, reserve, endBlock, tokenId);
        nftContract.safeTransferTo(msg.sender, newAuction, tokenId);
        auctions.push(newAuction);
    }

    // function getAuctionsByNFT(uint256 tokenId) public view {
    //     for(uint256 auctions )
    // }

}
