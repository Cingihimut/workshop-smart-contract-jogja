// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MemeToken} from "../src/MemeToken.sol";

contract MemeTokenScript is Script {
    MemeToken public memeToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        memeToken = new MemeToken("MemeToken", "MTK");
        console.log("MemeToken created at", address(memeToken));

        vm.stopBroadcast();
    }
}

// forge script MemeTokenScript --rpc-url https://base-mainnet.g.alchemy.com/v2/Ea4M-V84UObD22z2nNlwDD9qP8eqZuSI --broadcast --verify --etherscan-api-key ZT932TH1YXFN81TX26ZZTE99KB8K3G294M