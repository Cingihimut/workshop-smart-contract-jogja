// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {

    address public owner;
    uint256 public constant MAX_TOTAL_SUPPLY = 10_000;

    constructor() ERC20("Djarum Super", "DJs") {
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "only owner can mint");
        require(totalSupply() + amount <= MAX_TOTAL_SUPPLY, "max supply exceeded");
        _mint(to, amount);
    }

}
