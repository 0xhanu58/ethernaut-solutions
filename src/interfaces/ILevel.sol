// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

interface ILevel {
  function createInstance(address _player) external payable returns (address);
  function validateInstance(address payable _instance, address _player) external returns (bool);
}