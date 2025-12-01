// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ITerminal.sol";
import "./TerminalStorage.sol";
import "./BlobKitEHoF.sol";

contract BaseTerminal is ITerminal, TerminalStorage, BlobKitEHoF {
    constructor() {
        // Initialize game state
        gameActive = true;
        timeRemaining = block.timestamp + DURATION;
        emit TimerReset(timeRemaining);
    }

    function bid() external payable override {
        if (!gameActive) revert GameNotActive();
        if (block.timestamp >= timeRemaining) revert GameNotActive(); // Game technically ended, waiting for claim
        if (msg.value < MIN_BID) revert InsufficientFee();

        currentLeader = msg.sender;
        potBalance += msg.value;
        timeRemaining = block.timestamp + DURATION;

        emit Bid(msg.sender, msg.value, potBalance, block.timestamp);
        emit TimerReset(timeRemaining);
    }

    function claim() external override {
        if (block.timestamp < timeRemaining) revert GameActive();
        if (!gameActive) revert GameNotActive();

        uint256 amount = potBalance;
        address winner = currentLeader;

        // Update state before external calls (Checks-Effects-Interactions)
        gameActive = false;
        potBalance = 0;
        currentLeader = address(0);

        // Record winner in Ephemeral Hall of Fame
        _recordWinner(winner, amount);

        (bool success, ) = winner.call{value: amount}("");
        if (!success) revert TransferFailed();

        emit PotClaimed(winner, amount, block.timestamp);
    }

    function bump() external override {
        // Gasless interaction to keep the chain alive or just check status
        // This function satisfies the "Bump" requirement for the Gasless Grant
        // It can be called by a Paymaster to ensure the contract state is fresh
        // or to trigger specific time-based logic if we add it later.
        if (block.timestamp >= timeRemaining && gameActive) {
            // In a future version, this could auto-claim or reset
        }
    }
}
