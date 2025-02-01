//SPDX-License-Identifier: MIT

import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

pragma solidity ^0.8.13;

contract Vault is ERC20 {

    error AmountCannotBeZero();

    event Deposit(address user, uint256 amount, uint256 shares);
    event Withdraw(address user, uint256 amount, uint256 shares);

    address public assetToken;
    address public owner;

    constructor(address _assetToken) ERC20("Deposito Vault", "DEPO") {
        assetToken = _assetToken;
        owner = msg.sender;
    }

    function deposit(uint256 amount) external {
        if(amount == 0) revert AmountCannotBeZero();
        //deposit amount / total asset * total shares
        uint256 shares = 0;
        uint256 totalAsets = IERC20(assetToken).balanceOf(address(this));

        if(totalSupply() == 0){
            shares = amount;
        } else {
            shares = (amount * totalSupply() / totalAsets);
        }

        _mint(msg.sender, shares);
        IERC20(assetToken).transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, amount, shares);
    }

    function withdraw(uint256 shares) external {
        //withdraw shares / total shares * total asset
        uint256 totalAsets = IERC20(assetToken).balanceOf(address(this));
        uint256 amount = (shares * totalAsets / totalSupply());

        _burn(msg.sender, shares);
        IERC20(assetToken).transfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount, shares);
    }

    function distributeYield(uint256 amount) external {
        require(msg.sender == owner, "Only owner can distribute yield");

        IERC20(assetToken).transferFrom(msg.sender, address(this), amount);
    }

}
