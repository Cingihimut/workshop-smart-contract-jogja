// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {

    Token public token;

    function setUp() public {
        token = new Token();
    }

    function test_mint() public {
        token.mint(address(this), 1000);
        assertEq(token.balanceOf(address(this)), 1000, "balance should be 1000");
    }

    function test_mint_max_supply() public {
        vm.expectRevert("max supply exceeded");
        token.mint(address(this), 10000000);
    }
    
}
