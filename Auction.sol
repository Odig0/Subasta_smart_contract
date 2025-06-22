// SPDX-License-Identifier: MIT
/// @author Diego Guzman
pragma solidity ^0.8.26;


/// @title Subastas
contract AuctionBasic {
    address public owner;
    address public highestBidder;
    uint public highestBid;
    uint public auctionEndTime;
    bool public ended;

    mapping(address => uint) public bids;
    address[] public bidders;

    uint public constant COMMISSION_PERCENT = 2;  /// POrcenatje de la comision
    uint public constant MIN_INCREMENT_PERCENT = 5; ///el minimo porcentaje para que haya una nueva subasta

    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el propietario puee llamar ");
        _;
    }

    modifier auctionActive() {
        require(block.timestamp < auctionEndTime && !ended, "Auction is not active");
        _;
    }

    constructor(uint durationMinutes) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + durationMinutes * 1 minutes;
    }

    function bid() external payable auctionActive {
        require(msg.value > 0, "Send ETH to bid");

        uint newBid = bids[msg.sender] + msg.value;

        require(
            newBid >= highestBid + (highestBid * MIN_INCREMENT_PERCENT / 100),
            "Bid must be at least 5% higher than current highest"
        );

        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }

        bids[msg.sender] = newBid;
        highestBid = newBid;
        highestBidder = msg.sender;

        // Extiende si se oferta en los últimos 10 minutos
        if (auctionEndTime - block.timestamp <= 10 minutes) {
            auctionEndTime += 10 minutes;
        }

        emit NewBid(msg.sender, newBid);
    }

    function endAuction() external onlyOwner {
        require(!ended, "Auction already ended");
        require(block.timestamp >= auctionEndTime, "Auction still active");

        ended = true;

        uint commission = (highestBid * COMMISSION_PERCENT) / 100;
        uint sellerAmount = highestBid - commission;

        payable(owner).transfer(sellerAmount);
        emit AuctionEnded(highestBidder, highestBid);
    }

    function withdraw() external {
        require(ended, "Auction not yet ended");
        require(msg.sender != highestBidder, "Winner cannot withdraw");

        uint amount = bids[msg.sender];
        require(amount > 0, "No funds to withdraw");

        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function getBiddersAndBids() external view returns (address[] memory, uint[] memory) {
        uint[] memory values = new uint[](bidders.length);
        for (uint i = 0; i < bidders.length; i++) {
            values[i] = bids[bidders[i]];
        }
        return (bidders, values);
    }
}
