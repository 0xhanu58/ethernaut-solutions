// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ILevel.sol";

interface IEthernaut {
    function createLevelInstance(ILevel _level) external payable;
    function submitLevelInstance(address payable _instance) external;
}
