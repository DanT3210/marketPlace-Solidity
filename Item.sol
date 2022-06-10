// SPDX-License-Identifier:MIT
pragma solidity ^0.8.14;

import "./ItemLibrary.sol";

contract Item {
    address payable buyerAccount;
    address payable developer;    
    ItemLibrary.itemStatus item_status;      
    uint256 devFee;
    //uint256 public cTotal;
    uint startDate;
    uint endDate;
    bool internal locked;
    //Item Array
    ItemLibrary.itemListed[] public itemList;    
    //****************************************************************************************************************************************************************************************************
 
    //Constructor
    constructor(address _mainContract,address _seller, string memory _brand, string memory _model, string memory _description, uint256 _price, string memory _size, uint8 _qty) payable{
        itemList.push(ItemLibrary.itemListed(payable (_mainContract),payable (_seller), payable (buyerAccount),_brand, _model,_description,"New",item_status,_price,_size, _qty));
        developer = payable (0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        devFee= 5126770;
    }
    //****************************************************************************************************************************************************************************************************


    //*******************************MODIFIERS************************************************
    //Review modifier (publish s_contract with developer and update owners (publishers)
     modifier onlySeller() {
      require(msg.sender == itemList[0].seller);
      _;
    }

    modifier onlyBuyer (){
        require(msg.sender == itemList[0].buyerAccount, "You're not the Buyer of this Item");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
    //*****************************************************************************************

    //************FUNCTIONS****************************************************************************************************************************************************************************************
    //Function Buy Item 
    function buyItem() external payable{
       if(itemList[0]._itemPrice<=(msg.value) && itemList[0].item_status==ItemLibrary.itemStatus.Listed){
            itemList[0].buyerAccount=payable(msg.sender);
            itemList[0].item_status=ItemLibrary.itemStatus.Sold;
            //itemList[0].qtyInStock=0;
            //cTotal=address(this).balance;
        }    
        else{
            revert("Not enough founds or item sold!");
        }
    }   
    
    //Ship Item
    function shipItem(uint256 _trackNo) public onlySeller{ 
        if(itemList[0].item_status==ItemLibrary.itemStatus.Sold && address(this).balance==itemList[0]._itemPrice){
            itemList[0].item_status=ItemLibrary.itemStatus.Shipped;
            startDate=block.timestamp;
            emit ItemLibrary.transLog(itemList[0].seller, itemList[0]._itemPrice, "Shipped",_trackNo, startDate);
            startDate=block.timestamp+7 minutes; //receiving Date (send date+N Days)
        }else {
            revert("error");
        }
    }   

    //Received Item
    function receivedItem(string calldata _review) public onlyBuyer{
        require (itemList[0].item_status==ItemLibrary.itemStatus.Shipped, "Item hasn't been shipped yet");
        itemList[0].item_status=ItemLibrary.itemStatus.Received;
        endDate=block.timestamp; //received Day
        emit ItemLibrary.transLog(itemList[0].seller, itemList[0]._itemPrice, _review,0, endDate);
    }   
    
    //Return Item
    function returnItem(uint _trackNo) public onlyBuyer{
        require (itemList[0].item_status==ItemLibrary.itemStatus.Received, "Item hasn't been received yet");
        itemList[0].item_status=ItemLibrary.itemStatus.Return_Request;
        startDate=block.timestamp;
        emit ItemLibrary.transLog(itemList[0].seller, itemList[0]._itemPrice, "Returned",_trackNo, startDate);
        endDate=0; //reset endDate to 0
    }   

    //Cancel Transaction
    function cancelTransaction () external onlyBuyer{
        require (itemList[0].item_status==ItemLibrary.itemStatus.Sold, "Item has been shipped already");
        developer.transfer(devFee/2);
        itemList[0].item_status=ItemLibrary.itemStatus.Canceled;
        itemList[0].buyerAccount.transfer(address(this).balance);
        startDate=block.timestamp;
        emit ItemLibrary.transLog(itemList[0].seller, itemList[0]._itemPrice, "Cancelled",0, startDate);
    }  

    //Withdraw funds
    function realeaseFunds() external onlySeller noReentrant{
        if ((block.timestamp>=(endDate + 1 minutes) && itemList[0].item_status==ItemLibrary.itemStatus.Received) || block.timestamp>=(startDate + 3 minutes) && itemList[0].item_status==ItemLibrary.itemStatus.Shipped){
            developer.transfer(devFee);
            itemList[0].seller.transfer(address(this).balance);
            //cTotal=0;
            //itemList[0].item_status=itemStatus.Received;
            endDate=block.timestamp;
            emit ItemLibrary.transLog(itemList[0].seller, itemList[0]._itemPrice, "Fund has been released",0, endDate);            
        } else {
            revert("ERROR");
        }        
    }

    //Check balance
    function myBalance() public view returns (uint256){
            return address(this).balance;
    }

}