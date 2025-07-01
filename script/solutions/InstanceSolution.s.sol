// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Vm} from "forge-std/Vm.sol";
import {Level, IEthernaut} from "../../src/interfaces/IEthernaut.sol";
import {Instance} from "ethernaut/contracts/src/levels/Instance.sol";
// import {Instance, InstanceFactory} from "ethernaut/contracts/src/levels/InstanceFactory.sol";

contract InstanceSolution is Script {
    function run() external {
        uint pvtKey = vm.envUint("METAMASK_PRIVATE_KEY");
        address myAddr = vm.addr(pvtKey);
        console.log("Address:",myAddr);

        Level instanceFactory = Level(0x7E0f53981657345B31C59aC44e9c21631Ce710c7);
        IEthernaut ethernaut = IEthernaut(0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6);

        vm.startBroadcast(pvtKey);

        // 🔍 Record logs emitted during tx
        vm.recordLogs();
        ethernaut.createLevelInstance(instanceFactory);

        // 📦 Read the logs
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 topic0 = keccak256("LevelInstanceCreatedLog(address,address,address)");

        address deployedInstanceByEthernaut;
        for (uint256 i = 0; i < entries.length; ++i) {
            Vm.Log memory log = entries[i];
            if (log.topics[0] == topic0) {
                address player = address(uint160(uint256(log.topics[1])));
                if (player == myAddr) {
                    deployedInstanceByEthernaut = address(uint160(uint256(log.topics[2])));
                    break;
                }
            }
        }

        require(deployedInstanceByEthernaut != address(0), "Could not find instance log");
        console.log("Instance deployed at:", deployedInstanceByEthernaut);

        Instance instance = Instance(deployedInstanceByEthernaut);
        console.log("Address of instance:",address(instance));

        // solving the chal
        string memory pass = instance.password();
        console.log("Password for instance:",pass);
        instance.authenticate(pass);

        // submitting on ethernaut
        ethernaut.submitLevelInstance(payable(address(instance)));
        
        console.log("Level Completed");


        vm.stopBroadcast();
    }
}