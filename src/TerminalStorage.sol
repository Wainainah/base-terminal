// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TerminalStorage {
    address public currentLeader;
    uint256 public timeRemaining; // Timestamp when the timer expires
    uint256 public potBalance;
    bool public gameActive;
    
    uint256 public constant DURATION = 24 hours;
    uint256 public constant MIN_BID = 0.001 ether;
}
