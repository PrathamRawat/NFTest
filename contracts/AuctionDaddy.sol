pragma solidity ^0.5.0;

import "./nft-contract.sol";

contract Bid {

    address bidder;
    uint256 bid;

    constructor (address bidderAccount, uint256 bidAmount) public {
        bidder = bidderAccount;
        bid = bidAmount;
    }
}

contract Auction is IERC721Receiver {

    bool open;
    address seller;
    uint256 startingBid;
    uint256 reservePrice;
    uint256 endBlock;
    uint256 tokenId;
    Bid[] bids;

    uint256 maxBid;
    address payable maxBidder;

    MintableToken tokenContract = MintableToken(0xBe99Fb75bD331387958019Efe30C0F0Aa78D5DbD);

    constructor (address sellerAccount, uint256 startingBidAmount, uint256 reservePriceAmount, uint256 endBlockLevel, uint256 nftTokenId) public {
        // _registerInterface(IERC721Receiver.onERC721Received.selector);

        seller = sellerAccount;
        startingBid = startingBidAmount;
        reservePrice = reservePriceAmount;
        endBlock = endBlockLevel;
        maxBid = startingBid;
        maxBidder = address(0);
        tokenId = nftTokenId;
        open = true;
        // tokenContract.safeTransferFrom();
    }

    function getMaxBid() public view returns (uint256) {
        return maxBid;
    }

    function getMaxBidder() public view returns (address){
        return maxBidder;
    }

    function getStartingPrice() public view returns (uint256){
        return startingBid;
    }

    function getEndBlock() public view returns (uint256){
        return endBlock;
    }

    function getBids() public view returns (Bid[] memory){
        return bids;
    }

    function isAuctionFinished() public view returns (bool){
        return endBlock >= block.number;
    }

    function cancelAuction() public {
        require(open, "This auction is already closed.");
        require(msg.sender == seller, "Only the seller can close this auction");
        require(msg.sender != address(0));
        open = false;
        if(maxBidder != address(0)) {
            maxBidder.transfer(maxBid);
        }
    }

    function bid() public payable {
        require(open, "This auction has been closed.");
        require(msg.value > maxBid, "Your bid should be greater than the maximum bid.");
        require(msg.sender != address(0));
        require(block.number >= endBlock, "This auction has expired.");
        //        Add more error cases
        maxBidder.transfer(maxBid); // Returns old bid back to the previous bidder
        maxBid = msg.value;
        maxBidder = msg.sender;
        bids.push(new Bid(msg.sender, msg.value));
    }

    function transferItems() public {
        require(msg.sender == seller || msg.sender == maxBidder, "Operation not permitted.");
        require(open, "This auction has been closed by the owner.");
        require(block.number > endBlock, "This auction has not ended yet.");
        maxBidder.transfer(maxBid);
        tokenContract.safeTransferFrom(address(this), maxBidder, tokenId);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,uint256,bytes)"));
    }
}


contract AuctionDaddy {

    Auction[] auctions;
    MintableToken nftContract = MintableToken(0xBe99Fb75bD331387958019Efe30C0F0Aa78D5DbD);

    constructor () public {}

    function createNewAuction(uint256 endBlock, uint256 reserve, uint256 tokenId, uint256 startingBid) public {
        require(msg.sender == nftContract.ownerOf(tokenId), "You must be the owner of an NFT to sell that NFT");
        require(endBlock - block.number < 100, "Auction will end too soon");

        Auction newAuction = new Auction(msg.sender, startingBid, reserve, endBlock, tokenId);
        nftContract.safeTransferFrom(msg.sender, address(newAuction), tokenId);
        auctions.push(newAuction);
    }

    // function getAuctionsByNFT(uint256 tokenId) public view {
    //     for(uint256 auctions )
    // }

}
