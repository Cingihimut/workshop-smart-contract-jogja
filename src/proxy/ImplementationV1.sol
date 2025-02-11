// SPDX-License-Identifire: MIT

pragma solidity ^0.8.13;

import {Initializable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

contract ImplementationV1 is Initializable {
    uint256 public price;
    address public assertToken;
    address public owner;

    contracts() {
        _disableInitializers();
    }

    function initialize(address _assertToken) public initializer {
        assertToken = _assertToken;
        owner = msg.sender;
    }

    function setPrice() public {
        require(msg.sender == owner, "Only owner can set the price");
        price = newPrice;
    }
}