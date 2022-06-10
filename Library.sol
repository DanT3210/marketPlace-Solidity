// SPDX-License-Identifier:MIT
pragma solidity ^0.8.14;

library ItemLibrary {
  
    enum itemStatus{Listed,Sold, Shipped,Transit, Received, Return_Request, Canceled}
    //*********************Struc******************************************************
    struct itemListed {
        address payable parentContract; 
        address payable seller;
        address payable buyerAccount;
        string brand;
        string model;
        string description;
        string Condition;
        itemStatus item_status;
        uint256 _itemPrice;
        string Size;
        uint8 qtyInStock; 
    }

    //*************************EVENT***********************************************************
      event transLog(address payable _buyer, uint _price, string _message, uint256 _trackNo, uint _date);
    //*****************************************************************************************

    //FUNTIONS*************************************************************************
    /*function libBuyItem(uint256 _amount, uint256 _price, itemStatus _status)public pure returns(bool, itemStatus){
        return (_price<=_amount, _status=itemStatus.Listed);
    }  */
}