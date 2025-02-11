// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LendingPool} from "./LendingPool.sol";

contract Factory {
    function createLendingPool(address _collateralToken, address _debtToken, address _oracle, uint256 _ltv) public returns (address) {
        LendingPool lendingPool = new LendingPool(_collateralToken, _debtToken, _oracle, _ltv);
        return address(lendingPool);
    }
}