pragma solidity ^0.4.0;

import "./nft-contract.sol";

contract Bid {

    address bidder;
    uint256 bid;

    constructor (address bidder, uint256 bid) {
        this.bidder = bidder;
        this.bid = bid;
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
    address maxBidder;

    MintableToken tokenContract = "0xBe99Fb75bD331387958019Efe30C0F0Aa78D5DbD";

    constructor (address owner, uint256 startingBid, uint256 reservePrice, uint256 endBlock, uint256 tokenId) {
        _registerInterface(IERC721Receiver.onERC721Received.selector);

        this.seller = seller;
        this.startingBid = startingBid;
        this.reservePrice = reservePrice;
        this.endBlock = endBlock;
        this.open = true;
        tokenContract.safeTransferFrom();
    }

    function getMaxBid() public view {
        return maxBid;
    }

    function getMaxBidder() public view {
        return maxBidder;
    }

    function getStartingPrice() public view {
        return startingPrice;
    }

    function getEndBlock() public view {
        return endBlock;
    }

    function getBids() public view {
        return bids;
    }

    function isAuctionFinished() {
        return endBlock >= block.number;
    }

    function cancelAuction() public onlyOwner {
        require(this.open == true, "This auction is already closed.");
        require(msg.sender != address(0));
        this.open = false;
        this.maxBidder.transfer(this.maxBid);
    }

    function bid() public payable {
        require(this.open == true, "This auction has been closed.");
        require(msg.value > this.maxBid, "Your bid should be greater than the maximum bid.");
        require(msg.sender != address(0));
        require(block.number >= this.endBlock, "This auction has expired.");
//        Add more error cases
        this.maxBidder.transfer(this.maxBid); // Returns old bid back to the previous bidder
        this.maxBid = msg.value;
        this.maxBidder = msg.sender;
        this.bids.push(new Bid(msg.sender, msg.value));
    }

    function transferItems() public {
        require(msg.sender == this.owner || msg.sender == this.maxBidder, "Operation not permitted.");
        require(this.open == true, "This auction has been closed by the owner.");
        require(block.number > this.endBlock, "This auction has not ended yet.");
        this.maxBidder.transfer(this.maxBid);
        tokenContract.safeTransferFrom(this, this.maxBidder, this.tokenId);
    }
}
