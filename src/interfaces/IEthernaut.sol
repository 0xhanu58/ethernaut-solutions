// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Level {
  function createInstance(address _player) external payable returns (address);
  function validateInstance(address payable _instance, address _player) external returns (bool);
}

interface IEthernaut {
    function createLevelInstance(Level _level) external payable;
    function submitLevelInstance(address payable _instance) external;
}

interface IStatistics {
    function saveNewLevel(address level) external;

    function createNewInstance(
        address instance,
        address level,
        address player
    ) external;

    function submitFailure(
        address instance,
        address level,
        address player
    ) external;

    function submitSuccess(
        address instance,
        address level,
        address player
    ) external;
}