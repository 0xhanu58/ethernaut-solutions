// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ILevel} from "../../src/interfaces/ILevel.sol";
import {Instance} from "ethernaut/contracts/src/levels/Instance.sol";
import {Helpers} from "../Helpers.s.sol";

contract InstanceSolution is Script, Helpers {
    uint pvtKey;
    address myAddr;
    address deployedInstanceByEthernaut;

    function run() external {
        pvtKey = vm.envUint("METAMASK_PRIVATE_KEY");
        myAddr = vm.addr(pvtKey);
        console.log("Address:",myAddr);

        ILevel level = ILevel(0x7E0f53981657345B31C59aC44e9c21631Ce710c7);
        
        vm.startBroadcast(pvtKey);
        
        deployedInstanceByEthernaut = createInstance(myAddr, level);

        Instance instance = Instance(deployedInstanceByEthernaut);

        // solving the chall
        string memory pass = instance.password();
        console.log("Password for instance:",pass);
        instance.authenticate(pass);

        // submitting on ethernaut
        submitInstance(deployedInstanceByEthernaut);

        vm.stopBroadcast();
    }
}