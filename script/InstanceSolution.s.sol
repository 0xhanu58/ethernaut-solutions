// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Level} from "../src/interfaces/IEthernaut.sol";
import {Instance} from "ethernaut/contracts/src/levels/Instance.sol";

contract InstanceSolution {
    function run() external pure {
        console.log("Hello");
    }
}