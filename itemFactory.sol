// SPDX-License-Identifier:MIT
pragma solidity ^0.8.14;

import "./Items.sol";

contract ItemFactory {
  Item[] public itemsArrs;
  Item addItem;

//********FUNCTIONS********************************************************************************************************************************************************************************************
//Create new  Item Contract 
  function ListItem(string memory _brand, string memory _model, string memory _description,uint256 _price, string memory _size, uint8 _qty) public {
    for(uint8 i=0; i<=_qty-1; i++){
     addItem = new Item(payable (address(this)),payable(msg.sender), _brand, _model,_description, _price, _size, 1);
     itemsArrs.push(addItem);
    } 
  }
}
