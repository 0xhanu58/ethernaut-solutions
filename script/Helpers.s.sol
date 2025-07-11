// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity >=0.6.2;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Vm} from "forge-std/Vm.sol";
import {ILevel, IEthernaut, IStatistics} from "../src/interfaces/IEthernaut.sol";

contract Helpers is Script {
    IEthernaut ethernaut = IEthernaut(0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6);
    IStatistics statistics; // 0x57d122d0355973dA78acF5138aE664548bB2CA2b for sepolia eth

    function getDeployedInstanceAddrByEthernaut(address myAddr, Vm.Log[] memory entries) public pure returns (address deployedInstanceByEthernaut) {
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
        // set statistics contract address
        statistics = ethernaut.statistics();
        console.log("Statistics Contract at:", address(ethernaut.statistics()));

        // record logs
        vm.recordLogs();
        ethernaut.createLevelInstance(level);

        // get instance address
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

    function getStats(address player) public view {
        console.log("No. of Levels completed:",statistics.getTotalNoOfLevelsCompletedByPlayer(player));
    }
}