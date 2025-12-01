// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title BlobKit Ephemeral Hall of Fame
/// @notice Stores the history of winners for the Base Terminal game.
/// @dev Designed to integrate with BlobKit SDK for off-chain indexing and visualization.
contract BlobKitEHoF {
    struct Winner {
        address addr;
        uint256 amount;
        uint256 timestamp;
    }

    Winner[] public hallOfFame;

    event WinnerRecorded(address indexed winner, uint256 amount, uint256 timestamp);

    /// @notice Records a new winner into the Hall of Fame
    /// @param _winner The address of the winner
    /// @param _amount The amount won
    function _recordWinner(address _winner, uint256 _amount) internal {
        hallOfFame.push(Winner(_winner, _amount, block.timestamp));
        emit WinnerRecorded(_winner, _amount, block.timestamp);
    }

    /// @notice Returns the total number of winners
    function getHallOfFameCount() external view returns (uint256) {
        return hallOfFame.length;
    }

    /// @notice Returns a specific winner by index
    /// @param _index The index of the winner
    function getWinner(uint256 _index) external view returns (Winner memory) {
        return hallOfFame[_index];
    }
}
