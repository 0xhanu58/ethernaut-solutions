// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

import "./ILevel.sol";
import "./IStatistics.sol";

abstract contract IEthernaut {
    IStatistics public statistics;

    function createLevelInstance(ILevel _level) external virtual payable;
    function submitLevelInstance(address payable _instance) external virtual;
}
