// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {BleepFulfill} from "../src/BleepFulfill.sol";
import {console} from "forge-std/console.sol";

contract DeployBleepFulfill is Script {
    function run() external {
        vm.startBroadcast();

        BleepFulfill bleepFulfill = new BleepFulfill();

        vm.stopBroadcast();

        console.log("BleepFulfill deployed to:", address(bleepFulfill));
    }
}