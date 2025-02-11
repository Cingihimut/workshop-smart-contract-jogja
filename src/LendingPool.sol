// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface Oracle {
  function getPrice() external view returns (uint256);
}

contract LendingPool  {

  //!Supply
  uint256 public totalSupplyShares;
  uint256 public totalSupplyAssets;
  //!Borrow
  uint256 public totalBorrowShares;
  uint256 public totalBorrowAssets;
  uint256 public lastAccrued = block.timestamp;
  uint256 public borrowRate = 1e17; //? 18 decimals setara 10%
  uint256 public ltv;
  address public debtToken;
  address public collateralToken;
  address public oracle;
  
  error ZeroAmount();
  error InsufficientShares();
  error InsufficientLiquidity();
  error InsufficientCollateral();
  error LTVExceedMaxAmount();
  error InvalidOracle();
  
  event Supply(address user, uint256 amount, uint256 shares);
  event Withdraw(address user, uint256 amount, uint256 shares);
  event SupplyCollateral(address user, uint256 amount);
  event Borrow(address user, uint256 amount, uint256 shares);
  event Repay(address user, uint256 amount, uint256 shares);
  event FlashLoanFailed(address token, uint256 amount);

  mapping(address => uint256) public userSupplyShares;
  mapping(address => uint256) public userBorrowShares;
  mapping(address => uint256) public userCollaterals;

  constructor(address _collateralToken, address _debtToken, address _oracle, uint256 _ltv) {
    collateralToken = _collateralToken;
    debtToken = _debtToken;
    oracle = _oracle;
    if(oracle == address(0)) revert InvalidOracle();
    if(_ltv > 1e18) revert LTVExceedMaxAmount();
    ltv = _ltv
  }

  function supply(uint256 amount) external {
    _accrueInterest();
    if (amount == 0) revert ZeroAmount();
    IERC20(debtToken).transferFrom(msg.sender,address(this),amount);

    uint256 shares = 0;
    if (totalSupplyShares == 0 ) {
      shares = amount;
    } else {
      shares = (amount * totalSupplyShares / totalSupplyAssets);
    }

    userSupplyShares[msg.sender] += shares;
    totalSupplyShares += shares;
    totalSupplyAssets += amount;

    emit Supply(msg.sender, amount, shares);
  }

  function borrow(uint256 amount) external {
    _accrueInterest();

    uint256 shares = 0;
    if (totalBorrowShares == 0 ) {
      shares = amount;
    } else {
      shares = (amount * totalBorrowShares / totalBorrowAssets);
    }

    _isHealthy(msg.sender);
    if(totalBorrowAssets > totalSupplyAssets) revert InsufficientLiquidity();

    userBorrowShares[msg.sender] += shares;
    totalBorrowShares += shares;
    totalBorrowAssets += amount;

    IERC20(debtToken).transfer(msg.sender, amount);

    emit Borrow(msg.sender, amount, shares);
  }

  function repay(uint256 shares) external {
    if(shares == 0) revert ZeroAmount();

    _accrueInterest();

    uint256 borrowAmount = (shares * totalBorrowAssets) / totalBorrowShares;

    userBorrowShares[msg.sender] -= shares;
    totalBorrowShares -= shares;
    totalBorrowAssets -= borrowAmount;

    IERC20(debtToken).transferFrom(msg.sender, address(this), borrowAmount);

    emit Repay(msg.sender, borrowAmount, shares);

  }

  function accureInterest() external {
    _accrueInterest();
  }

  function _accrueInterest() internal {

    uint256 interestPerYear = totalBorrowAssets * borrowRate/ 1e18;
    // 1000 * 1e17 / 1e18 = 100/year

    uint256 elapsedTime = block.timestamp - lastAccrued;
    // 1 hari 

    uint256 interest = (interestPerYear * elapsedTime) / 365 days;
    // interest = $100 * 1 hari / 365 hari  = $0.27

    totalSupplyAssets += interest;
    totalBorrowAssets += interest;
    lastAccrued = block.timestamp;
  }

  function supplyCollateral(uint256 amount) external {
    if(amount == 0) revert ZeroAmount();

    _accrueInterest();  

    IERC20(collateralToken).transferFrom(msg.sender, address(this), amount);

    userCollaterals[msg.sender] += amount;

    emit SupplyCollateral(msg.sender, amount);

  }

  function withdrawCollateral(uint256 amount) public {
    if(amount == 0) revert ZeroAmount();
    if(amount > userCollaterals[msg.sender]) revert InsufficientCollateral();

    _accrueInterest();

    userCollaterals[msg.sender] -= amount;

    _isHealthy(msg.sender);

    IERC20(collateralToken).transfer(msg.sender, amount);
  }

  function _isHealthy(address user) internal view {
    uint256 collateralPrice = IOracle(oracle).getPrice(); // harga WETH dalam USDC
    uint256 collateralDecimals = 10**IERC20Metadata(collateralToken).decimals(); // 1e18

    uint256 borrowed = userBorrowShares[user] * totalBorrowAssets / totalBorrowShares;

    uint256 collateralValue = userCollaterals[user] * collateralPrice / collateralDecimals;
    uint256 maxBorrow = collateralValue * ltv / 1e18;

    if (borrowed > maxBorrow) revert InsufficientCollateral();
  }

  function withdraw(uint256 shares) external {
    if(shares ==0) revert ZeroAmount();

    if(shares > userSupplyShares[msg.sender]) revert InsufficientShares();

    _accrueInterest();

    uint256 amount = (shares * totalSupplyAssets) / totalSupplyShares;

    userSupplyShares[msg.sender] -= shares;
    totalSupplyAssets -= amount;
    totalSupplyShares -= shares;

    if(totalSupplyAssets < totalBorrowAssets) revert InsufficientLiquidity();

    IERC20(debtToken).transfer(msg.sender, amount);

    emit Withdraw(msg.sender, amount, shares);
  }

  function flashLoan(address token, uint256 amount, calldata data) external {
    if(amount == 0) revert ZeroAmount();

    IERC20(token).transfer(msg.sender, amount);

    (bool success, ) = address(msg.sender).call(data);
    if(!success) revert FlashLoanFailed();

    IERC20(token).transfer(address(this), amount);
  }


}
