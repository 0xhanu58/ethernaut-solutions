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
    string private CACHE = string.concat(vm.projectRoot(), "/script/deployedInstances.json");

    struct Deployment {
        uint256 chainId;
        address levelFactoryAddress;
        address deployedInstance;
        address player;
    }

    // internal functions

    // ---------------------------------------------------------------------
    // read – returns an *array* of Deployment structs (empty if file absent)
    // ---------------------------------------------------------------------
    function _load() internal view returns (Deployment[] memory list) {
        if (!vm.exists(CACHE)) return new Deployment[](0) ;

        string memory json = vm.readFile(CACHE);
        if (bytes(json).length == 0) return new Deployment[](0);

        bytes memory raw = vm.parseJsonBytes(json, ".records");
        list = abi.decode(raw, (Deployment[]));
    }

    // ---------------------------------------------------------------------
    // write – encodes an array back to disk as { "records": [...] }
    // ---------------------------------------------------------------------
    function _save(Deployment[] memory list) internal {
        bytes memory raw = abi.encode(list);
        string memory json = vm.serializeBytes("tmp", "records", raw);
        // `serializeBytes` returns the whole json with key "tmp"
        vm.writeFile(CACHE, json);
    }

    // ---------------------------------------------------------------------
    // append a record & persist
    // ---------------------------------------------------------------------
    function _append(Deployment memory rec) internal {
        Deployment[] memory list = _load();
        Deployment[] memory big  = new Deployment[](list.length + 1);
        for (uint i; i < list.length; ++i) big[i] = list[i];
        big[list.length] = rec;
        _save(big);
    }

    // ---------------------------------------------------------------------
    // removes a record
    // ---------------------------------------------------------------------

    function _remove(address instanceAddr) internal {
        Deployment[] memory records = _load();
        uint len = records.length;
        if (len == 0) return;

        // Create a new array with filtered records
        Deployment[] memory updated = new Deployment[](len);
        uint count = 0;

        for (uint i = 0; i < len; ++i) {
            if (records[i].deployedInstance != instanceAddr) {
                updated[count] = records[i];
                count++;
            }
        }

        // Resize the array
        Deployment[] memory trimmed = new Deployment[](count);
        for (uint i = 0; i < count; ++i) {
            trimmed[i] = updated[i];
        }

        _save(trimmed);
        console.log("Removed instance from cache:", instanceAddr);
    }


    // ---------------------------------------------------------------------
    // find a record and returns its instance
    // ---------------------------------------------------------------------

    function _findExistingInstance(
        address myAddr,
        address levelFactory
    ) private view returns (address instance) {
        Deployment[] memory records = _load();
        uint256 chainId = block.chainid;

        for (uint i = 0; i < records.length; ++i) {
            if (
                records[i].chainId == chainId &&
                records[i].player == myAddr &&
                records[i].levelFactoryAddress == levelFactory
            ) {
                return records[i].deployedInstance;
            }
        }

        return address(0); // not found
    }


    // public functions

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
        console.log("Ethernaut Contract at:", address(address(ethernaut)));
        console.log("Statistics Contract at:", address(ethernaut.statistics()));

        // check if instance already there or not
        // check cache
        address cached = _findExistingInstance(myAddr, address(level));
        if (cached != address(0)) {
            console.log("Using previously deployed instance:", cached);
            return cached;
        }

        // record logs
        vm.recordLogs();
        ethernaut.createLevelInstance(level);

        // get instance address
        Vm.Log[] memory entries = vm.getRecordedLogs();
        deployedInstanceByEthernaut = getDeployedInstanceAddrByEthernaut(myAddr,entries);
        require(deployedInstanceByEthernaut != address(0), "Could not find instance log");
        console.log("Instance deployed at:", deployedInstanceByEthernaut);

        // save to cache
        Deployment memory newRecord = Deployment({
            chainId: block.chainid,
            levelFactoryAddress: address(level),
            deployedInstance: deployedInstanceByEthernaut,
            player: myAddr
        });
        _append(newRecord);

        return deployedInstanceByEthernaut;
    }

    function submitInstance(address instanceAddr) public {
        ethernaut.submitLevelInstance(payable(instanceAddr));
        console.log("Level Completed! Congrats!");

        // Optional: remove from cache
        _remove(instanceAddr);
    }

    function getStats(address player) public view {
        console.log("No. of Levels completed:",statistics.getTotalNoOfLevelsCompletedByPlayer(player));
    }
}