// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

interface IStatistics {

    // player statistics

    function getTotalNoOfLevelInstancesCreatedByPlayer(address player) external view returns (uint256);

    function getTotalNoOfLevelInstancesCompletedByPlayer(address player) external view returns (uint256);

    function getTotalNoOfFailedSubmissionsByPlayer(address player) external view returns (uint256);

    function getTotalNoOfLevelsCompletedByPlayer(address player) external view returns (uint256);

    function getTotalNoOfFailuresForLevelAndPlayer(address level, address player) external view returns (uint256);

    function isLevelCompleted(address player, address level) external view returns (bool);

    function getTimeElapsedForCompletionOfLevel(address player, address level) external view returns (uint256);

    function getSubmissionsForLevelByPlayer(address player, address level, uint256 index) external view returns (uint256);

    function getPercentageOfLevelsCompleted(address player) external view returns (uint256);

    // Game Specific Statistics

    function getTotalNoOfLevelInstancesCreated() external view returns (uint256);

    function getTotalNoOfLevelInstancesCompleted() external view returns (uint256);

    function getTotalNoOfFailedSubmissions() external view returns (uint256);

    function getTotalNoOfPlayers() external view returns (uint256);

    function getNoOfFailedSubmissionsForLevel(address level) external view returns (uint256);

    function getNoOfInstancesForLevel(address level) external view returns (uint256);

    function getNoOfCompletedSubmissionsForLevel(address level) external view returns (uint256);

    // Internal Functions

    function doesLevelExist(address level) external view returns (bool);

    function doesPlayerExist(address player) external view returns (bool);

    function getTotalNoOfEthernautLevels() external view returns (uint256);

    function getAverageTimeTakenToCompleteLevels(address player) external view returns (uint256);
}