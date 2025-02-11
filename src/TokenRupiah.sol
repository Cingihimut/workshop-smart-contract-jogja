//SPDX-License-Identifier: MIT

import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

pragma solidity ^0.8.13;

contract TokenRupiah is ERC20 {
    constructor(address _to, uint256 amount) ERC20("Token Rupiah", "TIDR") {
        _mint(_to, amount);
    }
}