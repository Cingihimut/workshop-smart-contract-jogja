//SPDX-License-Identifier: MIT

import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { ERC20Upgradeable } from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import { ReentrancyGuardUpgradeable } from "openzeppelin-contracts-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol";
import { Initializable } from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import { SafeERC20Upgradeable } from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/SafeERC20Upgradeable.sol";
import {TransparentUpgradeableProxy} from "openzeppelin-contracts-upgradeable/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

pragma solidity ^0.8.13;

contract VaultUpgradeable is Initializable, ERC20Upgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20Upgradeable for IERC20;

    //TODO: CHECK, EFFECT, INTERACTION
    //TODO: SAFETRANSFER
    //TODO: VALIDASI YANG CUKUP
    //TODO: OWNERSHIP MENGGUNAKAN SAFE WALLET https://app.safe.global/transactions multisig
    //TODO: TIMELOCK
    //TODO: ROUNDING UP & ROUNDING DOWN
    //TODO: ORACLE MANIPULATION
    //TODO: INFLATION ATTACK = bisa menggunakan openzeppelin erc4626

    //TODO: PASTIKAN VALIDASINYA BENAR DAN TIDAK ADA YANG TERLEWAT

    error AmountCannotBeZero();

    event Deposit(address user, uint256 amount, uint256 shares);
    event Withdraw(address user, uint256 amount, uint256 shares);

    address public assetToken;
    address public owner;

    uint256 public constant version = 1;

    constructor() {
        _disableInitializers(); //constructor tidak boleh dijalankan 
    }

    // sebagai gantinya menggunakan initializer
    function initialize(address _assetToken) initializer external {
        __ERC20_init("Deposito Vault", "DEPO");
        __ReentrancyGuard_init();

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
