// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./IBlobKitEHoF.sol";

contract BaseTerminal is Ownable, ReentrancyGuard, IBlobKitEHoF {
    // --- State Variables ---
    uint256 public currentRoundStart;
    uint256 public roundId;

    // --- Configuration ---
    uint256 public constant DURATION = 15 minutes;
    uint256 public constant START_PRICE = 0.01 ether;
    uint256 public constant RESERVE_PRICE = 0.0001 ether;

    // --- Errors ---
    error InsufficientPayment(uint256 required, uint256 provided);
    error TransferFailed();

    constructor() Ownable(msg.sender) {
        // Start the first round immediately upon deployment
        currentRoundStart = block.timestamp;
        roundId = 1;
    }

    // --- View Functions ---

    function getCurrentPrice() public view returns (uint256) {
        uint256 elapsed = block.timestamp - currentRoundStart;
        if (elapsed >= DURATION) {
            return RESERVE_PRICE;
        }

        uint256 totalDrop = START_PRICE - RESERVE_PRICE;
        // Calculate drop: (totalDrop * elapsed) / DURATION
        uint256 currentDrop = (totalDrop * elapsed) / DURATION;

        return START_PRICE - currentDrop;
    }

    // --- User Actions ---

    function buy() external payable nonReentrant {
        uint256 price = getCurrentPrice();
        
        if (msg.value < price) {
            revert InsufficientPayment(price, msg.value);
        }

        // 1. Calculate Refund (if any)
        uint256 refund = msg.value - price;

        // 2. Effects: Reset for Next Round
        // Capture state for event before updating
        uint256 wonRoundId = roundId;
        
        roundId++;
        currentRoundStart = block.timestamp;

        // 3. Emit Win Event
        emit RoundWon(wonRoundId, msg.sender, price, block.timestamp);

        // 4. Interactions: Payouts
        
        // Send payment to Owner (Treasury)
        (bool successOwner, ) = owner().call{value: price}("");
        if (!successOwner) revert TransferFailed();

        // Send refund to Winner (if applicable)
        if (refund > 0) {
            (bool successRefund, ) = msg.sender.call{value: refund}("");
            if (!successRefund) revert TransferFailed();
        }
    }
}
