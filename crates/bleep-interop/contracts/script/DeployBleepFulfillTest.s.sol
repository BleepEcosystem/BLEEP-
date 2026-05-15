// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {BleepFulfillTest} from "../src/BleepFulfillTest.sol";
import {console} from "forge-std/console.sol";

contract DeployBleepFulfillTest is Script {
    function run() external {
        vm.startBroadcast();

        BleepFulfillTest bleepFulfill = new BleepFulfillTest();

        vm.stopBroadcast();

        console.log("BleepFulfillTest deployed to:", address(bleepFulfill));
    }
}