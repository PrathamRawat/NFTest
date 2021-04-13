pragma solidity ^0.5.0;

import "./nft-contract.sol";

contract Transfer is IERC721Receiver {

    bool open;
    address payable seller;
    uint256 price;
    uint256 tokenId;

    MintableToken tokenContract = MintableToken(0xBe99Fb75bD331387958019Efe30C0F0Aa78D5DbD);

    constructor (address payable sellerAccount, uint256 priceAmount, uint256 nftTokenId) public {
        seller = sellerAccount;
        price = priceAmount;
        tokenId = nftTokenId;
        open = true;
    }

    function getTokenId() public view returns (uint256) {
        return tokenId;
    }

    function isOpen() public view returns (bool) {
        return open;
    }

    function getPrice() public view returns (uint256){
        return price;
    }

    function setPrice(uint256 price) public {
        require(msg.sender == seller, "You can only change the price if you are the seller.");
        price = price;

    }

    function cancelSale() public {
        require(open, "This sale is already closed.");
        require(msg.sender == seller, "Only the seller can close this sale");
        require(msg.sender != address(0));
        open = false;
    }

    function transferItems() public payable {
        require(msg.sender == seller, "Operation not permitted.");
        require(open, "This sale has been closed by the owner.");
        require(msg.value >= price, "Not enough paid");
        seller.transfer(msg.value);
        tokenContract.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}


contract TransferDaddy is IERC721Receiver {

    MintableToken nftContract = MintableToken(0xBe99Fb75bD331387958019Efe30C0F0Aa78D5DbD);

    mapping(uint256 => Transfer) sales;
    uint256 numTransfers;

    constructor () public {
        numTransfers = 0;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function createNewSale(uint256 tokenId, uint256 price) public {
        require(address(this) == nftContract.ownerOf(tokenId), "Please transfer the NFT to this contract.");

        Transfer newSale = new Transfer(msg.sender, price, tokenId);
        nftContract.safeTransferFrom(address(this), address(newSale), tokenId);
        sales[numTransfers] = newSale;
        numTransfers += 1;
    }

    function getNumTransfers() public view returns (uint256) {
        return numTransfers;
    }

    function getSaleById(uint256 id) public view returns(Transfer) {
        return sales[id];
    }
}
