// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Lending} from "../src/Lending.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LendingTest is Test {

    Lending public lending;
    address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    function setUp() public {
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/jIQwSPn0l4YehffUHdlUcicsq1pMLEfu", 21748923);
        lending = new Lending();
    }

    function test_lending() public {
        deal(wbtc, address(this), 1e8);
        IERC20(wbtc).approve(address(lending), 1e8);
        lending.supplyAndBorrow(1e8, 1000e6);
        uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));
        console.log("USDC Balance", usdcBalance);
    }

    function test_lending_leverage() public {
        deal(wbtc, address(this), 1e8);
        IERC20(wbtc).approve(address(lending), 1e8);
        lending.leverage(1e8, 1000e6);
        uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));
        console.log("USDC Balance", usdcBalance);
    }
}
