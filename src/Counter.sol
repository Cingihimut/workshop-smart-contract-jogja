// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract Counter {

    uint256 public price;
    uint256 public number;
    address public owner;

    constructor() {
        owner = msg.sender;
        price = 100;
    }

    function setPrice(uint256 newPrice) public {
        require(msg.sender == owner, "only owner can set price");
        price = newPrice;
    }

    function setOwner(address newOwner) public {
        require(msg.sender == owner, "only owner can set owner");
        owner = newOwner;
    }

    function setNumber(uint256 _number) public {
        number = _number;
    }

    function increment() public {
        number += 1;
    }

}