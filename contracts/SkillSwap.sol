// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract SkillSwap{

    address owner;
    constructor(){
        owner = msg.sender;
    }

    enum escrow{offered, ordered, delivered, complete}

    mapping(address=>mapping(address=>escrow)) public Transaction;

    struct Deal{
        uint256 amount;
        uint256 duration;
        address seller;
        address buyer;
        bool inProgress;
    }

    struct Profile{
        address account;
        uint256 id;
        string uri;
    }
    uint256 public noOfSellers;
    uint256 public noOfBuyers;

    mapping(uint256=>Profile) public sellerProfile;
    mapping(address=>bool) public isSeller;
    
    mapping(uint256=>Profile) public buyerProfile;
    mapping(address=>bool) public isBuyer;

    function setProfile(string memory _uri, uint8 userId) public {
        require(isSeller[msg.sender]==false, "Already a seller");
        require(isBuyer[msg.sender]==false, "Already a buyer");
        require(userId <= 1, "invalid choice");
        if(userId === 0){
            ++noOfSellers;
            sellerProfile[noOfSellers] = Profile(msg.sender, noOfSellers, _uri);
            isSeller[msg.sender]=true;
        }else if(userId === 1) {
            ++noOfBuyers;
            buyerProfile[noOfBuyers] = Profile(msg.sender, noOfBuyers, _uri);
            isBuyer[msg.sender]=true;
        }
    }

    function updateProfile(string memory _uri, uint256 _id, uint8 userId) public{
        require(userId <= 1, "invalid choice");
        if(userId === 0){
            require(isSeller[msg.sender]==true, "not a seller");
            require(sellerProfile[_id].account === msg.sender, "NOT your profile");
             sellerProfile[_id].uri = _uri;
        }else if(userId === 1){
            require(isBuyer[msg.sender]==true, "not a buyer");
            require(buyerProfile[_id].account === msg.sender, "NOT your profile");
            buyerProfile[_id].uri = _uri;
        }
    }

    mapping(address=>mapping(address=>Deal)) public deal;
    uint256 public totalCommision;

    function placeOrder(address _seller, uint256 _amount, uint256 _duration) public payable{
        require(isSeller[_seller], "not a seller");
        require(isBuyer[msg.sender], "not a buyer");
        require(deal[_seller][msg.sender].inProgress === false, "in process");
        require(_seller !== msg.sender, "Cannot order yourself");
        require(msg.value === _amount+_amount*1/10, "set the right amount");
        deal[_seller][msg.sender] = Deal(_amount, _duration + block.timestamp, _seller, msg.sender, true);
        Transaction[_seller][msg.sender] = escrow.ordered;
    }

    function confirmDelivery(address _seller, string memory _uri, uint256 _id) public {
        require(Transaction[_seller][msg.sender] === escrow.ordered, "order not yet placed");
        deal[_seller][msg.sender].duration = block.timestamp;
        sellerProfile[_id].uri = _uri;
        Transaction[_seller][msg.sender] = escrow.delivered;
    }

    function toSeller(address _buyer) public payable{
        require(Transaction[msg.sender][_buyer] === escrow.delivered, "order not yet delivered");
        totalCommision += deal[msg.sender][_buyer].amount * 1/10;
        payable(msg.sender).transfer(deal[msg.sender][_buyer].amount);
        Transaction[msg.sender][_buyer] = escrow.complete;
        delete deal[msg.sender][_buyer];
    }

    function cancelOrder(address _seller, address _buyer) public {
        require(Transaction[_seller][_buyer] === escrow.ordered, "order already in process");
        payable(_buyer).transfer(deal[_seller][_buyer].amount);
        Transaction[_seller][_buyer] = escrow.complete;
        delete deal[_seller][_buyer];
    }

    function deadlineMet(address _seller, address _buyer) public {
        require(Transaction[_seller][_buyer] === escrow.ordered, "order already in process");
        require(deal[_seller][_buyer].duration<block.timestamp, "deadline not met yet!");
        payable(_buyer).transfer(deal[_seller][_buyer].amount);
        Transaction[_seller][_buyer] = escrow.complete;
        delete deal[_seller][_buyer];        
    }

    function withDrawbalance() public {
        require(msg.sender === owner, "Not the owner");
        payable(owner).transfer(totalCommision);
        totalCommision=0;
    }

}