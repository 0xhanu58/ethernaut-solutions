// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Vm} from "forge-std/Vm.sol";
import {ILevel, IEthernaut} from "../src/interfaces/IEthernaut.sol";

contract Helpers is Script {
    IEthernaut ethernaut = IEthernaut(0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6);

    function getDeployedInstanceAddrByEthernaut(address myAddr,Vm.Log[] memory entries) public pure returns (address deployedInstanceByEthernaut) {
        bytes32 topic0 = keccak256("LevelInstanceCreatedLog(address,address,address)");

        for (uint256 i = 0; i < entries.length; ++i) {
            Vm.Log memory log = entries[i];
            if (log.topics[0] == topic0) {
                address player = address(uint160(uint256(log.topics[1])));
                if (player == myAddr) {
                    deployedInstanceByEthernaut = address(uint160(uint256(log.topics[2])));
                    return deployedInstanceByEthernaut;
                }
            }
        }

        return address(0);
    }

    function createInstance(address myAddr, ILevel level) public returns (address deployedInstanceByEthernaut) {
        vm.recordLogs();
        ethernaut.createLevelInstance(level);

        Vm.Log[] memory entries = vm.getRecordedLogs();
        deployedInstanceByEthernaut = getDeployedInstanceAddrByEthernaut(myAddr,entries);
        require(deployedInstanceByEthernaut != address(0), "Could not find instance log");
        console.log("Instance deployed at:", deployedInstanceByEthernaut);

        return deployedInstanceByEthernaut;
    }

    function submitInstance(address instanceAddr) public {
        ethernaut.submitLevelInstance(payable(instanceAddr));
        console.log("Level Completed! Congrats!");
    }
}