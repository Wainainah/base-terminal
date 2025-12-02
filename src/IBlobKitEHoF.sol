// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IBlobKitEHoF {
    event RoundWon(
        uint256 indexed roundId,
        address indexed winner,
        uint256 pricePaid,
        uint256 timestamp
    );
}
