//SPDX-License-Identifier: MIT

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

pragma solidity ^0.8.13;

contract MemeToken is ERC20 {

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1_000_000_000_000_e18);
    }

}
